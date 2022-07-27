// Copyright 2022 The MITRE Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import '../../data_use_agreement/data_use_agreement.dart';

/// Class that describes the data for the onboarding comic.
/// Eventually there will be a way of loading this information from a JSON
/// object, and it will be made more complicated.
class OnboardingComic {
  const OnboardingComic(this.pages, this.dataUseAgreement);

  final List<OnboardingComicPage> pages;
  final DataUseAgreement dataUseAgreement;

  static Future<OnboardingComic> load(AssetBundle assetBundle) async {
    final data = json.decode(await assetBundle.loadString('assets/onboarding/onboarding.json'));
    if (data is! Map<String, dynamic>) {
      // Cannot parse
      throw const FormatException("Invalid object type for onboarding JSON");
    }
    final pagesData = data["pages"];
    if (pagesData is! List<dynamic>) {
      throw const FormatException("Missing page data");
    }
    final duaData = data["dataUseAgreement"];
    if (duaData is! Map<String, dynamic>) {
      throw const FormatException("Missing dataUseAgreement data");
    }
    // Parse the data
    var pages = <OnboardingComicPage>[];
    // For now the page number is simply a number that is increased with each
    // page. In the future, it will likely be replaced.
    int pageNumber = 1;
    for (final pageData in pagesData) {
      if (pageData is! Map<String, dynamic>) {
        log('Invalid object within page array, ignoring!', level: 900);
      } else {
        // Grab the page information
        final textData = pageData["text"];
        final nextLabelData = pageData["nextLabel"];
        if (textData is! String) {
          log('Invalid text object within page, skipping page!', level: 900);
          continue;
        }
        if (nextLabelData != null && nextLabelData is! String) {
          log('Invalid nextLabel object within page, skipping page!', level: 900);
          continue;
        }
        final nextLabel = nextLabelData == null ? null : nextLabelData as String;
        pages.add(
          OnboardingComicPage(
            pageNumber: pageNumber,
            firstPage: pageNumber == 1,
            altText: textData,
            nextLabel: nextLabel ?? "Next"
          )
        );
        // Increase the page number
        pageNumber++;
      }
    }
    return OnboardingComic(pages, DataUseAgreement.fromJson(duaData));
  }
}

class OnboardingComicPage {
  const OnboardingComicPage({
    required this.altText,
    required this.pageNumber,
    this.nextLabel="Next",
    this.firstPage=false
  });

  final String altText;
  final String nextLabel;
  /// Flag indicating that this page is the first page and that a shortcut to login should be present on this page
  final bool firstPage;
  final int pageNumber;
}