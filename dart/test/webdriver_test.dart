/*
 * Copyright 2014 Google Inc. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
library pageloader.test.webdriver;

import 'pageloader_test.dart' as plt;

import 'package:dart.testing/google3_test_util.dart';
import 'package:dart.testing/google3_vm_config.dart';
import 'package:testing.selenium.dart/builder.dart';

import 'package:pageloader/webdriver.dart';
import 'package:path/path.dart' as path;
import 'package:unittest/unittest.dart';
import 'package:sync_webdriver/sync_webdriver.dart' hide Platform;

import 'dart:async' show Future;
import 'dart:io';

/**
 * These tests are not expected to be run as part of normal automated testing,
 * as they are slow and they have external dependencies.
 */
void main() {
  useGoogle3VMConfiguration();

  WebDriver driver;

  setUp(() => freshDriver.then((d) {
    driver = d;
    driver.url = testPagePath;
    plt.loader = new WebDriverPageLoader(driver);
  }));

  plt.runTests();

  // This test needs to be last to properly close the browser.
  test('one-time teardown', () {
    closeDriver();
  });
}

String get testPagePath {
  if(_testPagePath == null) {
    _testPagePath = _getTestPagePath();
  }
  return _testPagePath;
}

String _getTestPagePath() {
  var testPagePath = path.join(
      runfilesDir, 'google3', 'third_party', 'dart',
      'pageloader', 'test', 'test_page.html');
  testPagePath = path.absolute(testPagePath);
  if(!FileSystemEntity.isFileSync(testPagePath)) {
    throw new Exception('Could not find the test file at "$testPagePath".'
        ' Make sure you are running tests from the root of the project.');
  }
  return path.toUri(testPagePath).toString();
}

String _testPagePath;

WebDriver _driver;

Future<WebDriver> get freshDriver {
  if (_driver != null) {
    try {
      Window firstWindow = null;

      for (Window window in _driver.windows) {
        if (firstWindow == null) {
          firstWindow = window;
        } else {
          _driver.switchTo.window(window);
          _driver.close();
        }
      }
      _driver.switchTo.window(firstWindow);
      _driver.url = 'about:';
    } catch (e) {
      closeDriver();
    }
  }
  if (_driver == null) {
    return buildSyncWebDriver().then((d) => _driver = d);
  }
  return new Future.value(_driver);
}

void closeDriver() {
  try {
    _driver.quit();
  } catch (e) { }
  _driver = null;
}
