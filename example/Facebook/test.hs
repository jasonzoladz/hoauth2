{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}

{- Facebook example -}

module Main where

import           Keys                       (facebookKey)
import           Network.OAuth.OAuth2

import           Data.Aeson                 (FromJSON)
import           Data.Aeson.TH              (defaultOptions, deriveJSON)
import qualified Data.ByteString.Char8      as BS
import qualified Data.ByteString.Lazy.Char8 as BL
import           Data.Text                  (Text)
import           Network.HTTP.Conduit
import           Prelude                    hiding (id)

--------------------------------------------------

data User = User { id    :: Text
                 , name  :: Text
                 , email :: Text
                 } deriving (Show)

$(deriveJSON defaultOptions ''User)

--------------------------------------------------

main :: IO ()
main = do
    print $ authorizationUrl facebookKey `appendQueryParam` facebookScope
    putStrLn "visit the url and paste code here: "
    code <- fmap BS.pack getLine

    mgr <- newManager tlsManagerSettings
    let (url, body) = accessTokenUrl facebookKey code
        url2 = appendQueryParam url (transform' [ ("client_id", Just $ oauthClientId facebookKey)
                                                , ("client_secret", Just $ oauthClientSecret facebookKey)
                                                , ("state", Just "test")
                                                ] ++ body)
    req2 <- parseUrl (BS.unpack url2)
    resp <- fmap (parseResponseJSON . handleResponse) (httpLbs req2 mgr)
    case (resp :: OAuth2Result AccessToken) of
      Right token -> do
                     print token
                     userinfo mgr token >>= print
      Left l -> print l

--------------------------------------------------
-- FaceBook API

-- | Gain read-only access to the user's id, name and email address.
facebookScope :: QueryParams
facebookScope = [("scope", "user_about_me,email")]

-- | Fetch user id and email.
userinfo :: FromJSON User => Manager -> AccessToken -> IO (OAuth2Result User)
userinfo mgr token = authGetJSON mgr token "https://graph.facebook.com/me?fields=id,name,email"
