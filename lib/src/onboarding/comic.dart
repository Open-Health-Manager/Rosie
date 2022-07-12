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

/// Class that describes the data for the onboarding comic.
/// Eventually there will be a way of loading this information from a JSON
/// object, and it will be made more complicated.
class OnboardingComic {
  const OnboardingComic(this.pages);

  final List<OnboardingComicPage> pages;

  static Future<OnboardingComic> load() async {
    // For now, this isn't really async
    // Eventually this will load initially from the internal
    // assets/comic/comic.json and then finally (most likely) from a web server
    return const OnboardingComic([
      OnboardingComicPage(pageNumber: 1, firstPage: true, altText: "Get control of your health. Follow me and learn how!"),
      OnboardingComicPage(pageNumber: 2, altText: "Your data can come from anywhere... from you, the doctor\u2019s office, or a device like your phone. We put it all in the same place."),
      OnboardingComicPage(pageNumber: 3, altText: "Now you can finally have one place to see your entire health picture."),
      OnboardingComicPage(pageNumber: 4, altText: "Mistakes Happen. This is why you can correct (with some exceptions) and annotate your data."),
      OnboardingComicPage(pageNumber: 5, altText: "You can share your data with anyone. We always need your permission before sharing your data."),
      OnboardingComicPage(pageNumber: 6, altText: "You can share your data with recommendation services to access suggestions for a healthier lifestyle."),
      OnboardingComicPage(pageNumber: 7, altText: "You can share data automatically during an emergency. First responders would be able to see critical health information about you."),
      OnboardingComicPage(pageNumber: 8, altText: "You can review who has access to your data.", nextLabel: "Half-way through, continue"),
      OnboardingComicPage(pageNumber: 9, altText: "You can stop sharing your data at any time."),
      OnboardingComicPage(pageNumber: 10, altText: "However, those you have shared with may keep a copy of your data. But, they cannot get any new data after you stop sharing."),
      OnboardingComicPage(pageNumber: 11, altText: "You can delete your data. We won\u2019t keep a copy. However, we can\u2019t make people delete the data you already shared with them."),
      OnboardingComicPage(pageNumber: 12, altText: "You can transfer your data. We won\u2019t keep a copy."),
      OnboardingComicPage(pageNumber: 13, altText: "We\u2019re responsible for keeping your data safe. You can hold us accountable if there is a data breach from Open Health Manager.")
    ]);
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