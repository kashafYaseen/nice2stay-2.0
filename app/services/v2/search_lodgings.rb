class V2::SearchLodgings
  attr_accessor :params
  attr_reader :custom_text, :only_parent, :check_ins, :check_outs

  def self.call(params, custom_text=nil, only_parent=false)
    self.new(params, custom_text, only_parent).call
  end

  def initialize(params, custom_text=nil, only_parent=false)
    @params = params
    @custom_text = custom_text
    @only_parent = only_parent
    @check_ins = check_in_dates
    @check_outs = check_out_dates
  end

  def call
    Lodging.search body: body, page: params[:page], per_page: 18, limit: params[:limit], includes: [:translations, :lodging_children, :children_room_rates, { price_text: :translations }, { region: :country }, { parent: :translations }]
  end

  private
    def query
      params[:query].presence || "*"
    end

    def body
      body = {}
      body[:query] = { has_child: { type: :child, query: { bool: boolean_queries } } }
      body[:sort] = [order] if order.present?
      body[:aggs] = aggregation
      body
    end

    def boolean_queries
      boolean_queries = {}
      boolean_queries[:filter] = conditions
      boolean_queries[:must_not] = { term: { id: params[:lodging_id] } } if params[:lodging_id].present?
      boolean_queries
    end

    def conditions
      conditions = []
      merge_seo_filters conditions
      conditions << { terms: { id: Lodging.search(params[:name_middle]).hits.collect{ |hit| hit['_id'].to_i } } } if params[:name_middle].present?
      conditions << { term: { published: true } }
      conditions << { terms: { id: params[:lodging_ids] } } if params[:lodging_ids].present?
      conditions << { term: { checked: params[:checked] } } if params[:checked].present?
      conditions << { term: { discounts: true } } if params[:discounts].present?
      conditions << { term: { realtime_availability: true } } if params[:realtime_availability].present?
      conditions << { term: { free_cancelation: true } } if params[:free_cancelation].present?

      conditions << { terms: { lodging_type: params[:lodging_type_in] } } if params[:lodging_type_in].present?

      # conditions << { terms: { presentation: ['as_child', 'as_standalone'] } } unless only_parent
      # conditions << { term: { presentation: 'as_child' } }

      conditions << { range: { beds: { gte: params[:beds], lte: params[:beds].to_i + 1 } } } if params[:beds].present?
      conditions << { range: { baths: { gte: params[:baths], lte: params[:baths].to_i + 1 } } } if params[:baths].present?
      conditions << { range: { adults: { gte: params[:adults].to_i } } } if params[:adults].present?
      conditions << { range: { adults_and_children: { gte: (params[:adults].to_i + params[:children].to_i) } } } if params[:adults].present?
      conditions << { range: { minimum_adults: { lte: params[:adults].to_i } } } if params[:adults].present?
      conditions << { range: { availability_price: { gte: params[:min_price], lte: params[:max_price] } } } if params[:min_price].present? && params[:max_price].present?

      if params[:countries_in].present? && params[:countries_in].reject(&:empty?).present? && params[:regions_in].present? && params[:bounds].blank?
        conditions << { bool: { should: [countries_in, regions_in] }}
      elsif params[:countries_in].present? && params[:countries_in].reject(&:empty?).present? && params[:bounds].blank?
        conditions << countries_in
      elsif params[:regions_in].present? && params[:regions_in].reject(&:empty?).present? && params[:bounds].blank?
        conditions << regions_in
      end

      if params[:flexible_arrival].blank? || (params[:flexible_arrival].present? && params[:flexible_type].present?)
        conditions << flexibility_condition if check_ins.present?
        conditions << minimum_stay_condition if check_ins.present? && check_outs.present?
      end
      # unless params[:flexible_arrival].present? || params[:flexible_type].blank?
      #   conditions << flexibility_condition if params[:check_in].present?
      #   conditions << minimum_stay_condition if params[:check_in].present? && params[:check_out].present?
      # end

      conditions << frame_coordinates if params[:bounds].present?
      conditions << near_latlong_condition if params[:within].present?

      availability_condition conditions if check_ins.present? || check_outs.present?
      all(:amenities_ids, params[:amenities_in], conditions) if params[:amenities_in].present?
      all(:experiences, params[:experiences_in], conditions) if params[:experiences_in].present?

      conditions
    end

    def countries_in
      { terms: { country: params[:countries_in] } }
    end

    def regions_in
      { terms: { region: params[:regions_in] } }
    end

    def aggregation
      {
        lodging_type: { terms: { field: :lodging_type } },
        countries: { terms: { field: :country_id } },
        amenities: { terms: { field: :amenities_ids, size: Amenity.count } },
        experiences: { terms: { field: :experiences_ids, size: Experience.count } },
        discounts: { terms: { field: :discounts } },
        checked: { terms: { field: :checked } },
        realtime_availability: { terms: { field: :realtime_availability } },
        free_cancelation: { terms: { field: :free_cancelation } },
      }
    end

    def frame_coordinates
      sw_lng, sw_lat, ne_lng, ne_lat = params[:bounds].split(",")
      return if sw_lng == ne_lng || sw_lat == ne_lat
      {
        geo_bounding_box: {
          location: {
            top_left: {
              lat: ne_lat,
              lon: sw_lng
            },
            bottom_right: {
              lat: sw_lat,
              lon: ne_lng
            }
          }
        }
      }
    end

    def near_condition
      location = Geocoder.search(params[:near]).first
      {
        near: {
          lat: location.latitude,
          lon: location.longitude
        },
        within: "3mi"
      }
    end

    def near_latlong_condition
      {
        geo_distance: {
          distance: params[:within],
          location: {
            lat: params[:latitude],
            lon: params[:longitude]
          },
        }
      }
    end

    def flexibility_condition
    {
      bool: {
        should: [
          { terms: { channel: ['open_gds', 'room_raccoon'] } },
          { match: { flexible_arrival: true } },
          {
            nested: {
              path: :rules,
              query: {
                bool: {
                  should: [
                    {
                      bool: {
                        must: [
                          { terms: { "rules.dates": check_ins } },
                          { match: { "rules.flexible_arrival": true } }
                        ]
                      }
                    },
                    {
                      bool: {
                        must: [
                          { terms: { "rules.dates": check_ins } },
                          { match: { "rules.flexible_arrival": false } },
                          { terms: { "rules.check_in_day": check_ins.map { |check_in| Date.parse(check_in).strftime("%A").downcase }.uniq }}
                        ]
                      }
                    }
                  ]
                }
              },
            },
          },
          {
            bool: {
              must: [
                { match: { flexible_arrival: false } },
                { terms: { check_in_day: check_ins.map { |check_in| Date.parse(check_in).strftime("%A").downcase }.uniq }}
              ]
            }
          }
        ]
      }
    }
    end

    def minimum_stay_condition
      nights = total_nights
      {
        bool: {
          filter: [
            {
              bool: {
                should: [
                  { terms: { channel: ['open_gds', 'room_raccoon'] } },
                  {
                    nested: {
                      path: :rules,
                      query: {
                        bool: {
                          should: [
                            {
                              bool: {
                                must: [
                                  { range: { "rules.minimum_stay": { lte: nights } } },
                                  { terms: { "rules.dates": check_ins } },
                                ]
                              }
                            },
                            {
                              bool: {
                                must: [
                                  { match: { "rules.minimum_stay": 0 } },
                                  { terms: { "rules.dates": check_ins } },
                                ]
                              }
                            },
                          ]
                        }
                      },
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    end

    def availability_condition conditions
      flexible_days = params[:flexible_days].presence || 3
      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      return conditions << available_on((Date.parse(check_in)..Date.parse(check_out)).map(&:to_s)) unless params[:flexible_arrival].present?

      dates = []
      if params[:flexible_type] == 'week'
        params[:flexible_dates].each do |date_range|
          dates << available_on((Date.parse(date_range[:check_in])..Date.parse(date_range[:check_out])).map(&:to_s))
        end
      else
        flexible_days.to_i.times do |index|
          dates << available_on(((Date.parse(check_in) + index.day)..Date.parse(check_out) + index.day).map(&:to_s))
          next if index == 0

          dates << available_on(((Date.parse(check_in) - index.day)..Date.parse(check_out) - index.day).map(&:to_s))
          dates << available_on(((Date.parse(check_in) + index.day)..Date.parse(check_out)).map(&:to_s))
          dates << available_on(((Date.parse(check_in))..Date.parse(check_out) - index.day).map(&:to_s))
          next unless index == 1

          dates << available_on(((Date.parse(check_in) + index.day)..Date.parse(check_out) - index.day).map(&:to_s))
        end
      end

      should = []
      should = { bool: { should: dates } }
      # dates.each { |date_range| should << { bool: { must: date_range } } }
      conditions << { bool: { must: should } }
    end

    def available_on(dates)
      _dates = []
      dates.each do |date|
        _dates << availability_check(date)
      end

      checkin_to_checkout_condition(dates, _dates)
    end

    def validate_check_in(date)
      {
        bool: {
          should: [
            {
              nested: {
                path: 'lodging_children',
                query: {
                  bool: {
                    must: [
                      {
                        nested: {
                          path: 'lodging_children.data.rules',
                          query: {
                            bool: {
                              should: [
                                { terms: { channel: ['open_gds', 'room_raccoon'] } },
                                { match: { 'lodging_children.data.flexible_arrival': true } },
                                {
                                  bool: {
                                    should: [
                                      {
                                        bool: {
                                          must: [
                                            { term: { 'lodging_children.data.rules.dates': date } },
                                            { match: { 'lodging_children.data.rules.flexible_arrival': true } }
                                          ]
                                        }
                                      },
                                      {
                                        bool: {
                                          must: [
                                            { term: { "lodging_children.data.rules.dates": date } },
                                            { match: { "lodging_children.data.rules.flexible_arrival": false } },
                                            { terms: { "lodging_children.data.rules.check_in_day": Date.parse(date).strftime("%A").downcase } }
                                          ]
                                        }
                                      }
                                    ]
                                  }
                                },
                                {
                                  bool: {
                                    must: [
                                      { match: { 'lodging_children.data.flexible_arrival': false } },
                                      { terms: { 'lodging_children.data.check_in_day': Date.parse(date).strftime("%A").downcase } }
                                    ]
                                  }
                                }
                              ]
                            }
                          }
                        }
                      },

                    ]
                  }
                }
              }
            }
          ]
        }
      }
    end


    def availability_check(date)
      {
        bool: {
          filter: {
            bool: {
              should: [
                {
                  nested: {
                    path: :availabilities,
                    query: {
                      bool: {
                        must: [
                          { term: { 'availabilities.available_on': date } },
                          { match: { 'availabilities.check_out_only': false } }
                        ]
                      }
                    }
                  }
                },
                {
                  nested: {
                    path: :room_rates,
                    query: {
                      bool: {
                        must: [
                          {
                            bool: {
                              must: [
                                { match: { 'room_rates.rate_enabled': true } },
                                {
                                  nested: {
                                    path: 'room_rates.availabilities',
                                    query: {
                                      bool: {
                                        must: [
                                          { term: { 'room_rates.availabilities.available_on': date } },
                                          { range: { 'room_rates.availabilities.rr_booking_limit': { gt: 0 } } },
                                        ]
                                      }
                                    }
                                  }
                                }
                              ]
                            }
                          }
                        ]
                      }
                    }
                  }
                }
              ]
            }
          }
        }
      }
    end

    def checkin_to_checkout_condition(dates, conditions)
      {
        bool: {
          must: [
            { bool: { must: conditions } },
            {
              bool: {
                should: [
                  {
                    bool: {
                      must: [
                        {
                          bool: {
                            must_not: [
                              { exists: { field: :checkout_dates } },
                              {
                                bool: {
                                  should: [
                                    {
                                      nested: {
                                        path: :room_rates,
                                        query: {
                                          bool: {
                                            must_not: [
                                              { exists: { field: 'room_rates' } }
                                            ]
                                          }
                                        }
                                      }
                                    }
                                  ]
                                }
                              }
                            ]
                          }
                        }
                      ]
                    }
                  },
                  {
                    bool: {
                      must: [
                        {
                          nested: {
                            path: 'room_rates.availabilities',
                            query: {
                              bool: {
                                must: [
                                  { term: { 'room_rates.availabilities.available_on': dates[0] } },
                                  { term: { 'room_rates.availabilities.rr_minimum_stay': total_nights.to_s } },
                                  { match: { 'room_rates.availabilities.rr_check_in_closed': false  } },
                                  { range: { "room_rates.availabilities.rr_booking_limit": { gt: 0 } } },
                                  {
                                    bool: {
                                      should: [
                                        {
                                          bool: {
                                            must_not: [
                                              { exists: { field: 'room_rates.availabilities.open_gds_restriction_days' } },
                                              { exists: { field: 'room_rates.availabilities.open_gds_restriction_type' } }
                                            ]
                                          }
                                        },
                                        {
                                          bool: {
                                            must: [
                                              { term: { 'room_rates.availabilities.open_gds_arrival_days': Date.parse(dates[0]).strftime("%A").downcase } },
                                              {
                                                bool: {
                                                  should: {
                                                    script: {
                                                      script: {
                                                        source: "String res_type = doc[\"room_rates.availabilities.open_gds_restriction_type\"].value; SimpleDateFormat sdf = new SimpleDateFormat(\"yyyy-MM-dd\"); try { long checkin_date = sdf.parse(params.checkin_date).getTime(); Calendar cal = Calendar.getInstance(); cal.add(Calendar.DATE, (int)doc[\"room_rates.availabilities.open_gds_restriction_days\"].value); long required_check_in = sdf.parse(sdf.format(cal.getTime())).getTime(); if(res_type == \"disabled\" || (res_type == \"till\" && checkin_date >= required_check_in) || (res_type == \"from\" && checkin_date <= required_check_in)) { return true; } return false; } catch(Exception e){ return false; }",
                                                        params: {
                                                         checkin_date: dates[0]
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            ]
                                          }
                                        }
                                      ]
                                    }
                                  }
                                ]
                              }
                            }
                          }
                        },
                        { term: { checkout_dates: dates[-1] } },
                      ]
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    end

    def order
      return { average_rating: :desc } if params[:order] == 'rating_desc'
      return { price: :asc } if params[:order] == 'price_asc'
      return { price: :desc } if params[:order] == 'price_desc'
      return { created_at: :desc } if params[:order] == 'new_desc'
      return { boost: :asc }
    end

    def merge_seo_filters conditions
      return unless custom_text.present?

      params[:experiences_in] = [custom_text.experience_slug] if custom_text.experience.present?
      params[:countries_in] = [custom_text.country_slug] if custom_text.country.present?
      params[:regions_in] = [custom_text.region_slug] if custom_text.region.present?
      params[:lodging_type_in] = [lodging_type(custom_text.category)] if custom_text.category?
      params[:discounts] = true if custom_text.special_offer?
    end

    def lodging_type(type)
      return 'villa' if ['villa', 'villas', 'vakantiehuizen'].include?(type)
      return 'apartment' if ['apartment', 'apartments', 'appartementen'].include?(type)
      return 'bnb' if ["boutique-hotels", "boutique-hotels", "bnb"].include?(type)
    end

    def all term, values, query
      values.each do |value|
        query << { term: { term => value } }
      end
      query
    end

    def check_in_dates
      dates = []
      if (params[:check_in].present? || params[:check_out].present?) && params[:flexible_arrival].blank?
        check_in = params[:check_in].presence || params[:check_out]
        dates << check_in
      else
        params[:months_date_range].each do |date_range|
          dates += (Date.parse(date_range[:start_date])..(Date.parse(date_range[:end_date]) - 7.days)).map(&:to_s) if params[:flexible_arrival].present? && params[:flexible_type] == 'week'
        end
      end

      dates
    end

    def check_out_dates
      dates = []
      if (params[:check_in].present? || params[:check_out].present?) && params[:flexible_arrival].blank?
        check_out = params[:check_out].presence || params[:check_in]
        dates << check_out
      elsif params[:flexible_arrival].present?
        params[:months_date_range].each do |date_range|
          dates += ((Date.parse(date_range[:start_date]) + 7.days)..(Date.parse(date_range[:end_date]))).map(&:to_s) if params[:flexible_type] == 'week'
        end
      end

      dates
    end

    def total_nights
      return 7 if params[:flexible_arrival].present? && params[:flexible_type] == 'week'

      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      return (Date.parse(check_out) - Date.parse(check_in)).to_i
    end
end
# {
                        #   nested: {
                        #     path: 'lodging_children',
                        #     query: {
                        #       bool: {
                        #         should: [
                        #           # {
                        #           #   nested: {
                        #           #     path: 'lodging_children.availabilities',
                        #           #     query: {
                        #           #       bool: {
                        #           #         must: [
                        #           #           { term: { 'lodging_children.availabilities.available_on': dates[0] },
                        #           #           {
                        #           #             nested: {
                        #           #               path: 'lodging_children.availabilities.rules',
                        #           #               query: {
                        #           #                 bool: {
                        #           #                   must: [
                        #           #                     {
                        #           #                       bool: {
                        #           #                         should: [
                        #           #                           { range: { 'lodging_children.availabilities.rules.minimum_stay': { lte: nights } } },
                        #           #                           { match: { 'lodging_children.availabilities.rules.minimum_stay': 0 } }
                        #           #                         ]
                        #           #                       }
                        #           #                     },
                        #           #                     {
                        #           #                       bool: {
                        #           #                         should: [
                        #           #                           # { terms: { channel: ['open_gds', 'room_raccoon'] } },
                        #           #                           { match: { 'lodging_children.flexible_arrival': true } },
                        #           #                           {
                        #           #                             bool: {
                        #           #                               should: [
                        #           #                                 { match: { 'lodging_children.availabilities.rules.flexible_arrival': true } },
                        #           #                                 {
                        #           #                                   bool: {
                        #           #                                     must: [
                        #           #                                       { match: { 'lodging_children.availabilities.rules.flexible_arrival': false } },
                        #           #                                       { terms: { 'lodging_children.availabilities.rules.check_in_day': Date.parse(dates[0]).strftime("%A").downcase } }
                        #           #                                     ]
                        #           #                                   }
                        #           #                                 }
                        #           #                               ]
                        #           #                             }
                        #           #                           },
                        #           #                           {
                        #           #                             bool: {
                        #           #                               must: [
                        #           #                                 { match: { 'lodging_children.flexible_arrival': false } },
                        #           #                                 { match: { 'lodging_children.check_in_day': dates[0].strftime("%A").downcase } }
                        #           #                               ]
                        #           #                             }
                        #           #                           },
                        #           #                         ]
                        #           #                       }
                        #           #                     }
                        #           #                   ]
                        #           #                 }
                        #           #               }
                        #           #             }
                        #           #           }
                        #           #         ]
                        #           #       }
                        #           #     }
                        #           #   }
                        #           # }
                        #         ]
                        #       }
                        #     }
                        #   }
                        # }


# {
                  #   bool: {
                  #     must: [
                  #       {
                  #         nested: {
                  #           path: 'room_rates.availabilities',
                  #           query: {
                  #             bool: {
                  #               must: [
                  #                 { term: { 'room_rates.availabilities.available_on': dates[0] } },
                  #                 { term: { 'room_rates.availabilities.rr_minimum_stay': total_nights.to_s } },
                  #                 { match: { 'room_rates.availabilities.rr_check_in_closed': false  } },
                  #                 { range: { "room_rates.availabilities.rr_booking_limit": { gt: 0 } } },
                  #                 {
                  #                   bool: {
                  #                     should: [
                  #                       {
                  #                         bool: {
                  #                           must_not: [
                  #                             { exists: { field: 'room_rates.availabilities.open_gds_restriction_days' } },
                  #                             { exists: { field: 'room_rates.availabilities.open_gds_restriction_type' } }
                  #                           ]
                  #                         }
                  #                       },
                  #                       {
                  #                         bool: {
                  #                           must: [
                  #                             { term: { 'room_rates.availabilities.open_gds_arrival_days': Date.parse(dates[0]).strftime("%A").downcase } },
                  #                             {
                  #                               bool: {
                  #                                 should: {
                  #                                   script: {
                  #                                     script: {
                  #                                       source: "String res_type = doc[\"room_rates.availabilities.open_gds_restriction_type\"].value; SimpleDateFormat sdf = new SimpleDateFormat(\"yyyy-MM-dd\"); try { long checkin_date = sdf.parse(params.checkin_date).getTime(); Calendar cal = Calendar.getInstance(); cal.add(Calendar.DATE, (int)doc[\"room_rates.availabilities.open_gds_restriction_days\"].value); long required_check_in = sdf.parse(sdf.format(cal.getTime())).getTime(); if(res_type == \"disabled\" || (res_type == \"till\" && checkin_date >= required_check_in) || (res_type == \"from\" && checkin_date <= required_check_in)) { return true; } return false; } catch(Exception e){ return false; }",
                  #                                       params: {
                  #                                        checkin_date: dates[0]
                  #                                       }
                  #                                     }
                  #                                   }
                  #                                 }
                  #                               }
                  #                             }
                  #                           ]
                  #                         }
                  #                       }
                  #                     ]
                  #                   }
                  #                 }
                  #               ]
                  #             }
                  #           }
                  #         }
                  #       },
                  #       { term: { checkout_dates: dates[-1] } },
                  #     ]
                  #   }
                  # }
