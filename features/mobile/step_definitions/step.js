const { Given, When, Then } = require('@cucumber/cucumber');

When("I click view with selector {kraken-string}", async function (selector) {
  var element = await this.driver.$(selector);
  return await element.click();
});
When("I enter text {kraken-string}", async function (text) {
  return await this.driver.keys(text);
});
