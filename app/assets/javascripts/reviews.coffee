(->
  window.Review or (window.Review = {})

  Review.init = ->
    $('.starrr').starrr()

    $('.starrr').on 'starrr:change', (e, value) ->
      $($(this).data('target')).val(value)

    $('.published').change ->
      $('.published:checked').not(this).prop 'checked', false

    $('.image_field').on 'change', ->
      if @files and @files[0]
        $('.feedback-images .custom-file-label').text("#{@files.length} #{if @files.length > 1 then 'Images' else 'Image'} Selected")
        $('#images_preview').html('')
        $(@files).each ->
          reader = new FileReader
          reader.readAsDataURL this

          reader.onload = (e) ->
            $('#images_preview').append "<img class='img-thumbnail mr-1 mb-3 col-2' src='#{e.target.result}'>"

).call this
