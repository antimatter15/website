_ = require('lodash')

module.exports = (env, callback) ->
  class AboutPage extends env.plugins.Page
    ### A page has a number and a list of articles ###

    constructor: (@articles) ->

    getFilename: -> "about/index.html"

    getView: -> (env, locals, contents, templates, callback) ->
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the pagination template
      template = templates['about.jade']
      if not template?
        return callback new Error "unknown about template"

      # setup the template context
      ctx = {@articles}

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback

  env.registerGenerator 'about', (contents, callback) ->
    
    rv = {}
    categories = env.helpers.getCategories(contents)
    rv['about'] = new AboutPage(categories['About'])

    callback null, rv


  callback()