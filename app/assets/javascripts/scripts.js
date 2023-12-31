/*
 * Unishop | Universal E-Commerce Template
 * Copyright 2018 rokaux
 * Theme Custom Scripts
 */
/*global jQuery, iziToast, noUiSlider*/
jQuery(document).on('turbolinks:load', function() {
  'use strict';

  // Check if Page Scrollbar is visible
  //---------------------------------------------------------------
  var hasScrollbar = function() {
    // The Modern solution
    if (typeof window.innerWidth === 'number') {
      return window.innerWidth > document.documentElement.clientWidth;
    }

    // rootElem for quirksmode
    var rootElem = document.documentElement || document.body;

    // Check overflow style property on body for fauxscrollbars
    var overflowStyle;

    if (typeof rootElem.currentStyle !== 'undefined') {
      overflowStyle = rootElem.currentStyle.overflow;
    }

    overflowStyle = overflowStyle || window.getComputedStyle(rootElem, '').overflow;

    // Also need to check the Y axis overflow
    var overflowYStyle;

    if (typeof rootElem.currentStyle !== 'undefined') {
      overflowYStyle = rootElem.currentStyle.overflowY;
    }

    overflowYStyle = overflowYStyle || window.getComputedStyle(rootElem, '').overflowY;

    var contentOverflows = rootElem.scrollHeight > rootElem.clientHeight;
    var overflowShown = /^(visible|auto)$/.test(overflowStyle) || /^(visible|auto)$/.test(overflowYStyle);
    var alwaysShowScroll = overflowStyle === 'scroll' || overflowYStyle === 'scroll';

    return (contentOverflows && overflowShown) || (alwaysShowScroll);
  };
  if (hasScrollbar()) {
    $('body').addClass('hasScrollbar');
  }


  // Disable default link behavior for dummy links that have href='#'
  //------------------------------------------------------------------
  var $emptyLink = $('a[href="#"]');
  $emptyLink.on('click', function(e) {
    e.preventDefault();
  });


  // Language Dropdown
  //----------------------------------------------------------------
  var langSwitcher = $('.lang-currency-switcher'),
    langToggle = $('.lang-currency-toggle');
  langToggle.on('click', function() {
    $(this).parent().addClass('open');
  });
  $(document).on('click', function(e) {
    if (!$(e.target).closest('.lang-currency-switcher').length) {
      $('.lang-currency-switcher').removeClass('open');
    }
  });


  // Slidable (Mobile) Menu
  //---------------------------------------------------------
  var backBtnText = 'Back',
    subMenu = $('.slideable-menu .slideable-submenu');
  subMenu.each(function() {
    $(this).prepend('<li class="back-btn"><a href="#">' + backBtnText + '</a></li>');
  });

  var hasChildLink = $('.has-children .sub-menu-toggle'),
    backBtn = $('.slideable-menu .slideable-submenu .back-btn');

  backBtn.on('click', function(e) {
    var self = this,
      parent = $(self).parent(),
      siblingParent = $(self).parent().parent().siblings().parent(),
      menu = $(self).parents('.menu'),
      menuInitHeight = $('.slideable-menu .menu').attr('data-height');
    parent.removeClass('in-view');
    siblingParent.removeClass('off-view');
    if (siblingParent.attr('class') === 'menu') {
      menu.css('height', menuInitHeight);
    } else {
      menu.css('height', siblingParent.height());
    }

    e.preventDefault();
  });

  hasChildLink.on('click', function(e) {
    var self = this,
      parent = $(self).parent().parent().parent(),
      menu = $(self).parents('.menu');

    parent.addClass('off-view');
    $(self).parent().parent().find('> .slideable-submenu').addClass('in-view');
    menu.css('height', $(self).parent().parent().find('> .slideable-submenu').height());

    e.preventDefault();
    return false;
  });

  // Animated Scroll to Top Button
  //-----------------------------------------------------------
  var $scrollTop = $('.scroll-to-top-btn');
  if ($scrollTop.length > 0) {
    $(window).on('scroll', function() {
      if ($(this).scrollTop() > 600) {
        $scrollTop.addClass('visible');
      } else {
        $scrollTop.removeClass('visible');
      }
    });
    $scrollTop.on('click', function(e) {
      e.preventDefault();
      $('html').velocity('scroll', {
        offset: 0,
        duration: 1200,
        easing: 'easeOutExpo',
        mobileHA: false
      });
    });
  }


  // Smooth scroll to element
  //---------------------------------------------------------
  $(document).on('click', '.scroll-to', function(event) {
    var target = $(this).attr('href');
    if ('#' === target) {
      return false;
    }

    var $target = $(target);
    if ($target.length > 0) {
      var $elemOffsetTop = $target.data('offset-top') || 70;
      $('html').velocity('scroll', {
        offset: $(this.hash).offset().top - $elemOffsetTop,
        duration: 1000,
        easing: 'easeOutExpo',
        mobileHA: false
      });
    }
    event.preventDefault();
  });


  // Filter List Groups
  //---------------------------------------------------------
  function filterList(trigger) {
    trigger.each(function() {
      var self = $(this),
        target = self.data('filter-list'),
        search = self.find('input[type=text]'),
        filters = self.find('input[type=radio]'),
        list = $(target).find('.list-group-item');

      // Search
      search.keyup(function() {
        var searchQuery = search.val();
        list.each(function() {
          var text = $(this).text().toLowerCase();
          (text.indexOf(searchQuery.toLowerCase()) == 0) ? $(this).show(): $(this).hide();
        });
      });

      // Filters
      filters.on('click', function(e) {
        var targetItem = $(this).val();
        if (targetItem !== 'all') {
          list.hide();
          $('[data-filter-item=' + targetItem + ']').show();
        } else {
          list.show();
        }

      });
    });
  }
  filterList($('[data-filter-list]'));

  // Shop Filters Toggle
  //-------------------------------------------------------------
  var filtersToggle = $('[data-toggle="filters"]'),
    filtersWrap = $('.filters-wrap'),
    filtersPane = $('.filters-pane');

  function closeFilterPane() {
    filtersToggle.removeClass('active');
    filtersPane.removeClass('open');
    filtersWrap.css('height', 0);
  }
  filtersToggle.on('click', function(e) {
    var currentFilter = $(this).attr('href');
    if ($(this).is('.active')) {
      closeFilterPane();
    } else {
      closeFilterPane();
      $(this).addClass('active');
      filtersWrap.css('height', $(currentFilter).outerHeight());
      $(currentFilter).addClass('open');
    }
    e.preventDefault();
  });
  if (typeof window.Modernizr !== "undefined" && !Modernizr.touch) {
    $(window).on('resize', function() {
      closeFilterPane();
    });
  }


  // Countdown Function
  //------------------------------------------------------------------------------
  function countDownFunc(items, trigger) {
    items.each(function() {
      var countDown = $(this),
        dateTime = $(this).data('date-time');

      var countDownTrigger = (trigger) ? trigger : countDown;
      countDownTrigger.downCount({
        date: dateTime,
        offset: +10
      });
    });
  }
  countDownFunc($('.countdown'));


  // Toast Notifications
  //------------------------------------------------------------------------------
  $('[data-toast]').on('click', function() {

    var self = $(this),
      $type = self.data('toast-type'),
      $icon = self.data('toast-icon'),
      $position = self.data('toast-position'),
      $title = self.data('toast-title'),
      $message = self.data('toast-message'),
      toastOptions = '';

    switch ($position) {
      case 'topRight':
        toastOptions = {
          class: 'iziToast-' + $type || '',
          title: $title || 'Title',
          message: $message || 'toast message',
          animateInside: false,
          position: 'topRight',
          progressBar: false,
          icon: $icon,
          timeout: 3200,
          transitionIn: 'fadeInLeft',
          transitionOut: 'fadeOut',
          transitionInMobile: 'fadeIn',
          transitionOutMobile: 'fadeOut'
        };
        break;
      case 'bottomRight':
        toastOptions = {
          class: 'iziToast-' + $type || '',
          title: $title || 'Title',
          message: $message || 'toast message',
          animateInside: false,
          position: 'bottomRight',
          progressBar: false,
          icon: $icon,
          timeout: 3200,
          transitionIn: 'fadeInLeft',
          transitionOut: 'fadeOut',
          transitionInMobile: 'fadeIn',
          transitionOutMobile: 'fadeOut'
        };
        break;
      case 'topLeft':
        toastOptions = {
          class: 'iziToast-' + $type || '',
          title: $title || 'Title',
          message: $message || 'toast message',
          animateInside: false,
          position: 'topLeft',
          progressBar: false,
          icon: $icon,
          timeout: 3200,
          transitionIn: 'fadeInRight',
          transitionOut: 'fadeOut',
          transitionInMobile: 'fadeIn',
          transitionOutMobile: 'fadeOut'
        };
        break;
      case 'bottomLeft':
        toastOptions = {
          class: 'iziToast-' + $type || '',
          title: $title || 'Title',
          message: $message || 'toast message',
          animateInside: false,
          position: 'bottomLeft',
          progressBar: false,
          icon: $icon,
          timeout: 3200,
          transitionIn: 'fadeInRight',
          transitionOut: 'fadeOut',
          transitionInMobile: 'fadeIn',
          transitionOutMobile: 'fadeOut'
        };
        break;
      case 'topCenter':
        toastOptions = {
          class: 'iziToast-' + $type || '',
          title: $title || 'Title',
          message: $message || 'toast message',
          animateInside: false,
          position: 'topCenter',
          progressBar: false,
          icon: $icon,
          timeout: 3200,
          transitionIn: 'fadeInDown',
          transitionOut: 'fadeOut',
          transitionInMobile: 'fadeIn',
          transitionOutMobile: 'fadeOut'
        };
        break;
      case 'bottomCenter':
        toastOptions = {
          class: 'iziToast-' + $type || '',
          title: $title || 'Title',
          message: $message || 'toast message',
          animateInside: false,
          position: 'bottomCenter',
          progressBar: false,
          icon: $icon,
          timeout: 3200,
          transitionIn: 'fadeInUp',
          transitionOut: 'fadeOut',
          transitionInMobile: 'fadeIn',
          transitionOutMobile: 'fadeOut'
        };
        break;
      default:
        toastOptions = {
          class: 'iziToast-' + $type || '',
          title: $title || 'Title',
          message: $message || 'toast message',
          animateInside: false,
          position: 'topRight',
          progressBar: false,
          icon: $icon,
          timeout: 3200,
          transitionIn: 'fadeInLeft',
          transitionOut: 'fadeOut',
          transitionInMobile: 'fadeIn',
          transitionOutMobile: 'fadeOut'
        };
    }

    iziToast.show(toastOptions);
  });


  // Wishlist Button
  //------------------------------------------------------------------------------
  $('.btn-wishlist').on('click', function() {
    $(this).toggleClass('text-danger');
    var iteration = $(this).data('iteration') || 1,
      toastOptions = {
        title: 'Product',
        animateInside: false,
        position: 'topRight',
        progressBar: false,
        timeout: 3200,
        transitionIn: 'fadeInLeft',
        transitionOut: 'fadeOut',
        transitionInMobile: 'fadeIn',
        transitionOutMobile: 'fadeOut'
      };

    switch (iteration) {
      case 1:
        $(this).addClass('active');
        toastOptions.class = 'iziToast-info';
        toastOptions.message = 'added to your wishlist!';
        toastOptions.icon = 'material-icons notifications_none';
        break;

      case 2:
        $(this).removeClass('active');
        toastOptions.class = 'iziToast-danger';
        toastOptions.message = 'removed from your wishlist!';
        toastOptions.icon = 'material-icons block';
        break;
    }

    iziToast.show(toastOptions);

    iteration++;
    if (iteration > 2) iteration = 1;
    $(this).data('iteration', iteration);
  });


  // Isotope Grid / Filters (Gallery)
  //------------------------------------------------------------------------------

  // Isotope Grid
  if ($('.isotope-grid').length) {
    var $grid = $('.isotope-grid').imagesLoaded(function() {
      $grid.isotope({
        itemSelector: '.grid-item',
        transitionDuration: '0.7s',
        masonry: {
          columnWidth: '.grid-sizer',
          gutter: '.gutter-sizer'
        }
      });
    });
  }

  // Filtering
  if ($('.filter-grid').length > 0) {
    var $filterGrid = $('.filter-grid');
    $('.nav-pills').on('click', 'a', function(e) {
      e.preventDefault();
      $('.nav-pills a').removeClass('active');
      $(this).addClass('active');
      var $filterValue = $(this).attr('data-filter');
      $filterGrid.isotope({
        filter: $filterValue
      });
    });
  }


  // Shop Categories Widget
  //------------------------------------------------------------------------------
  var categoryToggle = $('.widget-categories .has-children > a');

  function closeCategorySubmenu() {
    categoryToggle.parent().removeClass('expanded');
  }
  categoryToggle.on('click', function(e) {
    if ($(e.target).parent().is('.expanded')) {
      closeCategorySubmenu();
    } else {
      closeCategorySubmenu();
      $(this).parent().addClass('expanded');
    }
  });


  // Tooltips
  //------------------------------------------------------------------------------
  $('[data-toggle="tooltip"]').tooltip();


  // Popovers
  //------------------------------------------------------------------------------
  $('[data-toggle="popover"]').popover();


  // Interactive Credit Card
  //------------------------------------------------------------------------------
  var $creditCard = $('.interactive-credit-card');
  if ($creditCard.length) {
    $creditCard.card({
      form: '.interactive-credit-card',
      container: '.card-wrapper'
    });
  }


  // Gallery (Photoswipe)
  //------------------------------------------------------------------------------
  if ($('.gallery-wrapper').length) {

    var initPhotoSwipeFromDOM = function(gallerySelector) {

      // parse slide data (url, title, size ...) from DOM elements
      // (children of gallerySelector)
      var parseThumbnailElements = function(el) {
        var thumbElements = $(el).find('.gallery-item:not(.isotope-hidden)').get(),
          numNodes = thumbElements.length,
          items = [],
          figureEl,
          linkEl,
          size,
          item;

        for (var i = 0; i < numNodes; i++) {

          figureEl = thumbElements[i]; // <figure> element

          // include only element nodes
          if (figureEl.nodeType !== 1) {
            continue;
          }

          linkEl = figureEl.children[0]; // <a> element

          // create slide object
          if ($(linkEl).data('type') == 'video') {
            item = {
              html: $(linkEl).data('video')
            };
          } else {
            if (linkEl.getAttribute('data-size') == null){
              item = {
                src: linkEl.getAttribute('href'),
                w: parseInt(linkEl.childNodes[1].naturalWidth, 10),
                h: parseInt(linkEl.childNodes[1].naturalHeight, 10)
              };
            }
            else{
              size = linkEl.getAttribute('data-size').split('x');
              item = {
                src: linkEl.getAttribute('href'),
                w: parseInt(size[0], 10),
                h: parseInt(size[1], 10)
              };
            }
          }

          if (figureEl.children.length > 1) {
            // <figcaption> content
            item.title = $(figureEl).find('.caption').html();
          }

          if (linkEl.children.length > 0) {
            // <img> thumbnail element, retrieving thumbnail url
            item.msrc = linkEl.children[0].getAttribute('src');
          }

          item.el = figureEl; // save link to element for getThumbBoundsFn
          items.push(item);
        }

        return items;
      };

      // find nearest parent element
      var closest = function closest(el, fn) {
        return el && (fn(el) ? el : closest(el.parentNode, fn));
      };

      function hasClass(element, cls) {
        return (' ' + element.className + ' ').indexOf(' ' + cls + ' ') > -1;
      }

      // triggers when user clicks on thumbnail
      var onThumbnailsClick = function(e) {
        e = e || window.event;
        e.preventDefault ? e.preventDefault() : e.returnValue = false;

        var eTarget = e.target || e.srcElement;

        // find root element of slide
        var clickedListItem = closest(eTarget, function(el) {
          return (hasClass(el, 'gallery-item'));
        });

        if (!clickedListItem) {
          return;
        }

        // find index of clicked item by looping through all child nodes
        // alternatively, you may define index via data- attribute
        var clickedGallery = clickedListItem.closest('.gallery-wrapper'),
          childNodes = $(clickedListItem.closest('.gallery-wrapper')).find('.gallery-item:not(.isotope-hidden)').get(),
          numChildNodes = childNodes.length,
          nodeIndex = 0,
          index;

        for (var i = 0; i < numChildNodes; i++) {
          if (childNodes[i].nodeType !== 1) {
            continue;
          }

          if (childNodes[i] === clickedListItem) {
            index = nodeIndex;
            break;
          }
          nodeIndex++;
        }

        if (index >= 0) {
          // open PhotoSwipe if valid index found
          openPhotoSwipe(index, clickedGallery);
        }
        return false;
      };

      // parse picture index and gallery index from URL (#&pid=1&gid=2)
      var photoswipeParseHash = function() {
        var hash = window.location.hash.substring(1),
          params = {};

        if (hash.length < 5) {
          return params;
        }

        var vars = hash.split('&');
        for (var i = 0; i < vars.length; i++) {
          if (!vars[i]) {
            continue;
          }
          var pair = vars[i].split('=');
          if (pair.length < 2) {
            continue;
          }
          params[pair[0]] = pair[1];
        }

        if (params.gid) {
          params.gid = parseInt(params.gid, 10);
        }

        return params;
      };

      var openPhotoSwipe = function(index, galleryElement, disableAnimation, fromURL) {
        var pswpElement = document.querySelectorAll('.pswp')[0],
          gallery,
          options,
          items;

        items = parseThumbnailElements(galleryElement);

        // define options (if needed)
        options = {

          closeOnScroll: false,

          // define gallery index (for URL)
          galleryUID: galleryElement.getAttribute('data-pswp-uid'),

          getThumbBoundsFn: function(index) {
            // See Options -> getThumbBoundsFn section of documentation for more info
            var thumbnail = items[index].el.getElementsByTagName('img')[0]; // find thumbnail
            if ($(thumbnail).length > 0) {
              var pageYScroll = window.pageYOffset || document.documentElement.scrollTop,
                rect = thumbnail.getBoundingClientRect();

              return {
                x: rect.left,
                y: rect.top + pageYScroll,
                w: rect.width
              };
            }
          }

        };

        // PhotoSwipe opened from URL
        if (fromURL) {
          if (options.galleryPIDs) {
            // parse real index when custom PIDs are used
            // http://photoswipe.com/documentation/faq.html#custom-pid-in-url
            for (var j = 0; j < items.length; j++) {
              if (items[j].pid == index) {
                options.index = j;
                break;
              }
            }
          } else {
            // in URL indexes start from 1
            options.index = parseInt(index, 10) - 1;
          }
        } else {
          options.index = parseInt(index, 10);
        }

        // exit if index not found
        if (isNaN(options.index)) {
          return;
        }

        if (disableAnimation) {
          options.showAnimationDuration = 0;
        }

        // Pass data to PhotoSwipe and initialize it
        gallery = new PhotoSwipe(pswpElement, PhotoSwipeUI_Default, items, options);
        gallery.init();

        gallery.listen('beforeChange', function() {
          var currItem = $(gallery.currItem.container);
          $('.pswp__video').removeClass('active');
          var currItemIframe = currItem.find('.pswp__video').addClass('active');
          $('.pswp__video').each(function() {
            if (!$(this).hasClass('active')) {
              $(this).attr('src', $(this).attr('src'));
            }
          });
        });

        gallery.listen('close', function() {
          $('.pswp__video').each(function() {
            $(this).attr('src', $(this).attr('src'));
          });
        });

      };

      // loop through all gallery elements and bind events
      var galleryElements = document.querySelectorAll(gallerySelector);

      for (var i = 0, l = galleryElements.length; i < l; i++) {
        galleryElements[i].setAttribute('data-pswp-uid', i + 1);
        galleryElements[i].onclick = onThumbnailsClick;
      }

      // Parse URL and open gallery if it contains #&pid=3&gid=1
      var hashData = photoswipeParseHash();
      if (hashData.pid && hashData.gid) {
        openPhotoSwipe(hashData.pid, galleryElements[hashData.gid - 1], true, true);
      }

    };

    // execute above function
    initPhotoSwipeFromDOM('.gallery-wrapper');
  }


  // Product Gallery
  //------------------------------------------------------------------------------
  var $productCarousel = $('.product-carousel');
  if ($productCarousel.length) {

    // Carousel init
    $productCarousel.owlCarousel({
      items: 1,
      loop: false,
      dots: false,
      URLhashListener: true,
      startPosition: 'URLHash',
      onTranslate: activeHash
    });

    function activeHash(e) {
      var i = e.item.index;
      var $activeHash = $('.owl-item').eq(i).find('[data-hash]').attr('data-hash');
      $('.product-thumbnails li').removeClass('active');
      $('[href="#' + $activeHash + '"]').parent().addClass('active');
      $('.gallery-wrapper .gallery-item').removeClass('active');
      $('[data-hash="' + $activeHash + '"]').parent().addClass('active');

    }
  }


  // Google Maps API
  //------------------------------------------------------------------------------
  var $googleMap = $('.google-map');
  if ($googleMap.length) {
    $googleMap.each(function() {
      var mapHeight = $(this).data('height'),
        address = $(this).data('address'),
        zoom = $(this).data('zoom'),
        controls = $(this).data('disable-controls'),
        scrollwheel = $(this).data('scrollwheel'),
        marker = $(this).data('marker'),
        markerTitle = $(this).data('marker-title'),
        styles = $(this).data('styles');
      $(this).height(mapHeight);
      $(this).gmap3({
        marker: {
          address: address,
          data: markerTitle,
          options: {
            icon: marker
          },
          events: {
            mouseover: function(marker, event, context) {
              var map = $(this).gmap3('get'),
                infowindow = $(this).gmap3({
                  get: {
                    name: 'infowindow'
                  }
                });
              if (infowindow) {
                infowindow.open(map, marker);
                infowindow.setContent(context.data);
              } else {
                $(this).gmap3({
                  infowindow: {
                    anchor: marker,
                    options: {
                      content: context.data
                    }
                  }
                });
              }
            },
            mouseout: function() {
              var infowindow = $(this).gmap3({
                get: {
                  name: 'infowindow'
                }
              });
              if (infowindow) {
                infowindow.close();
              }
            }
          }
        },
        map: {
          options: {
            zoom: zoom,
            disableDefaultUI: controls,
            scrollwheel: scrollwheel,
            styles: styles
          }
        }
      });
    });
  }
}); /*Document Ready End*/
