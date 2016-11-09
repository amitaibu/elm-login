[![Build Status](https://travis-ci.org/Gizra/elm-hedley.svg?branch=master)](https://travis-ci.org/Gizra/elm-hedley)

> elm-hedley

## Installation

Make sure the following are installed:

* NodeJs (and npm)
* Elm (e.g. `npm install -g elm@0.17.0`)
* Compass (for SASS) (`gem update --system && gem install compass`)

## Usage

1. Serve locally, and watch file changes: `gulp`
1. Prepare file for publishing (e.g. minify, and rev file names): `gulp publish`
1. Deploy to GitHub's pages (`gh-pages` branch of your repository): `gulp deploy`

## Unit Tests

In order to view the tests on the browser Start elm reactor (elm-reactor) and navigate to http://0.0.0.0:8000/src/elm/TestRunner.elm

## License

MIT
