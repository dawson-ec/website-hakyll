--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do

    match "images/favicon.ico" $ do
        route   $ gsubRoute "images/" (const "")
        compile $ copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "content/*.md" $ do
        route   $ gsubRoute "content/" (const "") `composeRoutes` setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- tags <- buildTags "content/blog/*" (fromCapture "blog/tags/*.html")

    -- tagsRules tags $ \ tag pattern -> do
    --     let title = "Posts tagged \"" ++ tag ++ "\""
    --     route   idRoute
    --     compile $ do
    --         posts <- recentFirst =<< loadAll pattern
    --         let ctx = constField "title" title `mappend`
    --                   listField "posts" postCtx (return posts) `mappend`
    --                   defaultContext
    --         makeItem ""
    --             >>= loadAndApplyTemplate "templates/tag.html" ctx
    --             >>= loadAndApplyTemplate "templates/default.html" ctx
    --             >>= relativizeUrls

    -- match "content/blog/*" $ do
    --     route $ gsubRoute "content/" (const "") `composeRoutes` setExtension "html"
    --     compile $ pandocCompiler
    --         >>= saveSnapshot "tcontent"
    --         >>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags tags)
    --         >>= saveSnapshot "content"
    --         >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags tags)
    --         >>= relativizeUrls

    -- create ["blog.html"] $ do
    --     route idRoute
    --     compile $ do
    --         posts <- recentFirst =<< loadAll "content/blog/*"
    --         let archiveCtx =
    --                 boolField "hasposts" (\ p -> length p >= 1) `mappend`
    --                 listField "tags" defaultContext (return (collectTags tags)) `mappend`
    --                 listField "posts" postCtx (return posts)                    `mappend`
    --                 listField "latest" teaserCtx  (return $ take 3 posts)       `mappend`
    --                 constField "title" "Blog"                                   `mappend`
    --                 defaultContext
    --         makeItem ""
    --             >>= loadAndApplyTemplate "templates/blog.html" archiveCtx
    --             >>= loadAndApplyTemplate "templates/default.html" archiveCtx
    --             >>= relativizeUrls

    -- create ["atom.xml"] $ do
    --     route idRoute
    --     compile $ do
    --         let feedCtx = postCtx `mappend` bodyField "description"
    --         posts <- fmap (take 10) . recentFirst =<<
    --             loadAllSnapshots "content/blog/*" "content"
    --         renderAtom myFeedConfiguration feedCtx posts

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

postCtxWithTags :: Tags -> Context String
postCtxWithTags tags = tagsField "tags" tags `mappend` postCtx

teaserCtx :: Context String
teaserCtx = teaserField "teaser" "tcontent" `mappend` postCtx

collectTags tags = map ( \ (t, _) -> Item (tagsMakeId tags t) t) (tagsMap tags)

myFeedConfiguration :: FeedConfiguration
myFeedConfiguration = FeedConfiguration
    { feedTitle       = "Andrew Dawson - Blog"
    , feedDescription = "Blog entries"
    , feedAuthorName  = "Andrew Dawson"
    , feedAuthorEmail = "ajdawson@acm.org"
    , feedRoot        = "https://ajdawson.github.io"
    }
