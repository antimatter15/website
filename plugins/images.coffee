module.exports = (src) ->
  return src
  
  # return "http://i.imgur.com/rwd8s1N.jpg"

  # env.helpers.im = -> "http://i.imgur.com/Bc0Zuq1.jpg"
  # class ImageFile extends env.plugins.StaticFile
  #   constructor: (@filepath) ->
  #     console.log @filepath


  # ImageFile.fromFile = (filepath, callback) ->
  #   # console.log 'from file', filepath
  #   callback null, new this(filepath)
  # #   fs.readFile filepath.full, (err, data) =>
  # #     callback null, new this(filepath, yaml.load(data))

  # env.registerContentPlugin 'images', '**/*.*(png|jpg|jpeg)', ImageFile

  # callback()
