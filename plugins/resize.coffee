fs = require 'fs'
gm = require 'gm'

module.exports = (env, callback) ->


  class ScaledImage extends env.ContentPlugin
    ### based on the Static file handler. ###

    constructor: (@filepath, @size = 'medium') ->

    getView: ->
      return (args..., callback) ->
        # locals, contents etc not used in this plugin
        # console.log @filepath
        try
          gm(@filepath.full)
            .resize(600)
            .background('white')
            .flatten()
            .setFormat('jpeg')
            .stream (err, stdout, stderr) ->
              callback null, stdout
        catch error
          return callback error
        

    getFilename: -> @filepath.relative.replace(/\.[a-z]+$/g, '') + '-' + @size + '.jpg'

    getPluginColor: ->
      'none'

  getImages = (contents) ->
    images = []
    walk = (dir) ->
      for file in dir._.files
        if /\.(png|jpg|jpeg|gif|bmp|tif|webp)$/i.test(file.filename)
          images.push(file.filepath)
      dir._.directories.map(walk)
    walk(contents)
    return images

  env.registerGenerator 'imresize', (contents, callback) ->
    images = getImages(contents)
    rv = { }
    for image in images
      rv[image.relative + '.scaled'] = new ScaledImage(image)

    callback null, rv
  callback()