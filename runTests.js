var url = 'http://127.0.0.1:8080/test.html';

casper.options.waitTimeout = 60000;

casper.test.begin('Run the Elm tests', function suite(test) {
  casper.start(url).then(function() {
    // The test runner doesn't provide a class, so we have to do this query
    // selector.
    casper.waitForSelector('pre', function() {
      test.assertSelectorHasText('pre', 'All tests passed');
    });

  });

  casper.run(function() {
      test.done();
  });
});
