require 'test_helper'

class LodgingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lodging = lodgings(:one)
  end

  test "should get index" do
    get lodgings_url
    assert_response :success
  end

  test "should get new" do
    get new_lodging_url
    assert_response :success
  end

  test "should create lodging" do
    assert_difference('Lodging.count') do
      post lodgings_url, params: { lodging: { baths: @lodging.baths, beds: @lodging.beds, city: @lodging.city, latitude: @lodging.latitude, longitude: @lodging.longitude, price: @lodging.price, sale_date: @lodging.sale_date, sq__ft: @lodging.sq__ft, state: @lodging.state, street: @lodging.street, zip: @lodging.zip } }
    end

    assert_redirected_to lodging_url(Lodging.last)
  end

  test "should show lodging" do
    get lodging_url(@lodging)
    assert_response :success
  end

  test "should get edit" do
    get edit_lodging_url(@lodging)
    assert_response :success
  end

  test "should update lodging" do
    patch lodging_url(@lodging), params: { lodging: { baths: @lodging.baths, beds: @lodging.beds, city: @lodging.city, latitude: @lodging.latitude, longitude: @lodging.longitude, price: @lodging.price, sale_date: @lodging.sale_date, sq__ft: @lodging.sq__ft, state: @lodging.state, street: @lodging.street, zip: @lodging.zip } }
    assert_redirected_to lodging_url(@lodging)
  end

  test "should destroy lodging" do
    assert_difference('Lodging.count', -1) do
      delete lodging_url(@lodging)
    end

    assert_redirected_to lodgings_url
  end
end
