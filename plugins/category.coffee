module.exports = (env, callback) ->
  class CategoryPage extends env.plugins.Page
    ### A page has a number and a list of articles ###

    constructor: (@pageNum, @articles) ->

    getFilename: ->
      options.filename.replace '%d', @pageNum
      # if @pageNum is 1
      #   options.first
      # else
      #   options.filename.replace '%d', @pageNum

    getView: -> (env, locals, contents, templates, callback) ->
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the pagination template
      template = templates[options.template]
      if not template?
        return callback new Error "unknown paginator template '#{ options.template }'"

      # setup the template context
      ctx = {@articles, @pageNum, @prevPage, @nextPage}

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback



  # register a generator, 'paginator' here is the content group generated content will belong to
  # i.e. contents._.paginator
  env.registerGenerator 'cats', (contents, callback) ->
    # console.log contents
    # find all articles
    # articles = getArticles contents
    # tags = processTags articles
    

    # populate pages
    # numPages = Math.ceil articles.length / options.perPage
    # pages = []
    # for i in [0...numPages]
    #   pageArticles = articles.slice i * options.perPage, (i + 1) * options.perPage
    #   pages.push new PaginatorPage i + 1, pageArticles

    # # add references to prev/next to each page
    # for page, i in pages
    #   page.prevPage = pages[i - 1]
    #   page.nextPage = pages[i + 1]

    # # create the object that will be merged with the content tree (contents)
    # # do _not_ modify the tree directly inside a generator, consider it read-only
    # rv = { pages:{} }
    
    # for page in pages
    #   rv.pages["#{ page.pageNum }.page"] = page # file extension is arbitrary

    # rv['index.page'] = pages[0] # alias for first page
    # rv['last.page'] = pages[(numPages-1)] # alias for last page

    # # console.time('crate tag pags')
    # for tag in Object.keys(tags) when tags[tag].length > 1
    #   # arts = getArticlesByTag articles, tag
    #   rv.pages["#{ tag }.tag"] = new TagPage tag, tags[tag]
    # console.timeEnd('crate tag pags')
    # console.log rv
    # callback with the generated contents
    callback null, rv

  # add the article helper to the environment so we can use it later
  # env.helpers.getArticles = getArticles
  # env.helpers.isPopularTag = (tag) -> tag in allTags

  # tell the plugin manager we are done
  callback()
