(->
  window.Image or (window.Image = {})

  Image.init_preview = ->
    $('.image_field').on 'change', ->
      if @files[0]
        reader = new FileReader
        reader.onload = (e) ->
          $('.image_prev').attr 'src', e.target.result
        reader.readAsDataURL @files[0]

).call this
