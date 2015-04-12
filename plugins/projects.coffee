# async = require 'async'
fs = require 'fs'
# hljs = require 'highlight.js'
marked = require 'marked'
path = require 'path'
# url = require 'url'
yaml = require 'js-yaml'
slugify = require 'slugg'

module.exports = (env, callback) ->
  class ProjectsDocument extends env.plugins.StaticFile
    constructor: (@filepath, @metadata) ->
      @featured = @metadata.featured
      @projects = []
      for p in @featured
        @projects.push(p)
        if p.subprojects
          for s in p.subprojects
            s.parent = p
            @projects.push(s)

      for p in @projects
        if p.caption
          p.caption = marked(p.caption)
        p.related = p.subprojects || p?.parent?.subprojects && [p.parent].concat(k for k in p.parent.subprojects when k != p)
        p.url = "/project/#{slugify(p.title)}"


  ProjectsDocument.fromFile = (filepath, callback) ->
    fs.readFile filepath.full, (err, data) =>
      callback null, new this(filepath, yaml.load(data))

  env.registerContentPlugin 'pages', '**/projects.yaml', ProjectsDocument


  class CategoryListPage extends env.plugins.Page
    ### A page has a number and a list of articles ###

    constructor: (@categories) ->

    getFilename: -> 'category/index.html'

    getView: -> (env, locals, contents, templates, callback) ->
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the pagination template
      template = templates['categories.jade']
      if not template?
        return callback new Error "unknown paginator template '#{ options.template }'"

      # setup the template context
      ctx = {@categories}

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback


  class CategoryPage extends env.plugins.Page
    ### A page has a number and a list of articles ###
    constructor: (@category, @articles) ->

    getFilename: -> "category/#{slugify(@category)}/index.html"

    getView: -> (env, locals, contents, templates, callback) ->
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the pagination template
      template = templates['category.jade']

      # setup the template context
      ctx = {@articles, @category}

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback


  class ProjectPage extends env.plugins.Page
    ### A page has a number and a list of articles ###
    constructor: (@project, @articles) ->

    getFilename: -> "project/#{slugify(@project.title)}/index.html"

    getView: -> (env, locals, contents, templates, callback) ->
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the pagination template
      template = templates['project.jade']

      # setup the template context
      ctx = {@articles, @category, @project}

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback

  class ProjectListPage extends env.plugins.Page
    ### A page has a number and a list of articles ###
    constructor: () ->

    getFilename: -> "projects/index.html"

    getView: -> (env, locals, contents, templates, callback) ->
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the pagination template
      template = templates['projects.jade']

      # setup the template context
      ctx = {@articles}

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback


  # register a generator, 'paginator' here is the content group generated content will belong to
  # i.e. contents._.paginator
  env.registerGenerator 'catlist', (contents, callback) ->
    # console.log contents
    # find all articles
    # articles = getArticles contents
    # tags = processTags articles
    categories = { Uncategorized: [] }
    articles = env.helpers.getArticles(contents)
    for art in articles
      unless art?.metadata?.categories?.length
        categories['Uncategorized'].push art
        continue
      for cat in art?.metadata?.categories
        if cat not of categories
          categories[cat] = []
        categories[cat].push art


    # create the object that will be merged with the content tree (contents)
    # do _not_ modify the tree directly inside a generator, consider it read-only
    rv = { pages:{} }

    for category, posts of categories
      rv[category + '.cat'] = new CategoryPage(category, posts)

    rv['category.page'] = new CategoryListPage(categories)

    rv['projects.page'] = new ProjectListPage()

    # each project in contents['projects.yaml'].projects

    for project in contents['projects.yaml'].projects
      posts = []

      rv[project.title + '.project'] = new ProjectPage(project, posts)

    # console.log getArticles
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

  env.helpers.slugify = slugify

  callback()
