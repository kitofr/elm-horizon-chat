port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json


main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type UserState
    = Anon
    | Named


type alias Model =
    { userId : String
    , userName : String
    , input : String
    , messages : List Message
    , state : UserState
    }


type alias Message =
    { authorId : String
    , authorName : String
    , message : String
    }


type alias Flags =
    { userId : String
    }


emptyModel : Model
emptyModel =
    { userId = ""
    , input = ""
    , userName = ""
    , messages = []
    , state = Anon
    }


init : Flags -> ( Model, Cmd Msg )
init { userId } =
    { emptyModel
        | userId = userId
    }
        ! []



-- UPDATE


type Msg
    = NoOp
    | UpdateInput String
    | UpdateName String
    | Save
    | SaveName
    | Fetch (List Message)


port save : Message -> Cmd msg
port updateName : String -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        UpdateInput newInput ->
            { model | input = newInput }
                ! []

        UpdateName name ->
            { model | userName = name }
                ! []

        Save ->
            { model | input = "" }
                ! [ save (Message model.userId model.userName model.input) ]

        SaveName ->
          { model | state = Named } 
              ! [ updateName model.userName ] -- Here update rethink

        Fetch messages ->
            { model | messages = messages }
                ! []



-- SUBSCRIPTIONS


port fromHorizon : (List Message -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    fromHorizon Fetch



-- VIEW

message : String -> String
message name =
  "Say something ("  ++ name ++ "):"

view : Model -> Html Msg
view model =
  case model.state of
    Named ->
      div []
          [ h3 [] [ text ("Logged in as: " ++ model.userName) ]
          , ul [ class "message-list" ] (List.map chatMessage model.messages)
          , input
              [ type_ "text"
              , class "new-message-field"
              , autofocus True
              , placeholder (message model.userName) 
              , value model.input
              , onInput UpdateInput
              , onEnter NoOp Save
              ]
              []
          ]
    Anon ->
      div []
          [ ul [ class "message-list" ] (List.map chatMessage model.messages)
          , input
              [ type_ "text"
              , class "new-message-field"
              , placeholder "Enter your screen name"
              , autofocus True
              , value model.userName
              , onInput UpdateName
              , onEnter NoOp SaveName
              ]
              []
          ]



chatMessage : Message -> Html Msg
chatMessage { authorId, authorName, message } =
    let
        avatarUrl id =
            "http://api.adorable.io/avatars/50/" ++ id ++ ".png"

        id = if authorName == "" then
              authorId
             else
               authorName
    in
        li [ class "message" ]
            [ img [ class "avatar", src (avatarUrl id), alt id ] []
            , span [ class "message-text" ] [ text (id ++ " said: " ++ message) ]
            ]


onEnter : msg -> msg -> Attribute msg
onEnter fail success =
    let
        tagger code =
            if code == 13 then
                success
            else
                fail
    in
        on "keyup" (Json.map tagger keyCode)
