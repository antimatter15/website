fs = require 'fs'
gm = require 'gm'

module.exports = (env, callback) ->


  class ScaledImage extends env.ContentPlugin
    ### based on the Static file handler. ###

    constructor: (@filepath, @size = 'medium', @width = 500) ->

    getView: ->
      return (args..., callback) ->
        # locals, contents etc not used in this plugin
        # console.log @filepath
        try
          # callback null, fs.createReadStream(@filepath.full)
          # graphicsmagick is being shitty now
          gm(@filepath.full)
            .resize(@width + '>')
            .quality(86)
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
      # rv[image.relative + '.large'] = new ScaledImage(image, 'large', 200)
      rv[image.relative + '.medium'] = new ScaledImage(image, 'medium', 500)
      rv[image.relative + '.small'] = new ScaledImage(image, 'small', 200)

    callback null, rv
  callback()