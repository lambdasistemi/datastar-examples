module Examples.FileUpload
    ( fileUploadPage
    , fileUploadApp
    ) where

import Data.ByteString qualified as BS
import Data.ByteString.Lazy qualified as LBS
import Data.Text (Text, pack)
import Data.Text.Encoding qualified as TE
import Layout (examplePage, render)
import Lucid
import Lucid.Datastar
import Network.HTTP.Types (status200)
import Network.Wai
    ( Request
    , Response
    , getRequestBodyChunk
    , responseLBS
    )

fileUploadPage :: Html ()
fileUploadPage = examplePage "File Upload" $
    div_ [id_ "demo"] $ do
        input_
            ( [ type_ "file"
              , id_ "file-input"
              ]
                <> datastar
                    ( do
                        signal "fileData" "''"
                        onChange [] $
                            raw
                                "(() => { \
                                \const f = \
                                \document\
                                \.getElementById\
                                \('file-input')\
                                \.files[0]; \
                                \if(f) { \
                                \const r = new \
                                \FileReader(); \
                                \r.onload = (e) \
                                \=> { $fileData \
                                \= e.target\
                                \.result }; \
                                \r.readAsDataURL\
                                \(f) } })()"
                    )
            )
        div_ [id_ "result"] mempty
        button_
            ( datastar $
                on "click" [] $
                    act $
                        post (base <> "/upload")
            )
            "Upload"

base :: Text
base = "/examples/file-upload/data"

fileUploadApp
    :: Request -> (Response -> IO b) -> IO b
fileUploadApp req respond = do
    len <- countBody req 0
    let html = render $ resultHtml len
    respond $
        responseLBS
            status200
            [
                ( "Content-Type"
                , "text/html; charset=utf-8"
                )
            ]
            (LBS.fromStrict $ TE.encodeUtf8 html)

countBody :: Request -> Int -> IO Int
countBody req !acc = do
    chunk <- getRequestBodyChunk req
    if BS.null chunk
        then pure acc
        else countBody req (acc + BS.length chunk)

resultHtml :: Int -> Html ()
resultHtml len =
    div_ [id_ "demo"] $
        p_ $
            toHtml $
                "Received "
                    <> showBytes len
                    <> "."

showBytes :: Int -> Text
showBytes n
    | n < 1024 = pack (show n) <> " bytes"
    | n < 1024 * 1024 =
        pack (show (n `div` 1024)) <> " KB"
    | otherwise =
        pack
            ( show
                (n `div` (1024 * 1024))
            )
            <> " MB"
