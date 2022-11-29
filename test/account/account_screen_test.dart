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

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:rosie/src/account/account_screen.dart';
import 'package:rosie/src/open_health_manager/server_error_message.dart';

void main() {
  // Explicitly use English localizations for now
  final localizations = AppLocalizationsEn();
  group('createLocalizedErrorMessage', () {
    test('formats with no specific errors', () {
      expect(
        createLocalizedErrorMessage(
          const ServerErrorMessage(fieldErrors: []),
          localizations,
        ),
        equals(localizations.unknownServerError),
      );
    });

    test('returns the server error if no errors are listed', () {
      expect(
        createLocalizedErrorMessage(
          const ServerErrorMessage(
            title: 'Message from server',
            fieldErrors: [],
          ),
          localizations,
        ),
        equals('Message from server'),
      );
    });

    test('handles error with unknown fields', () {
      expect(
        createLocalizedErrorMessage(
            const ServerErrorMessage(
              title: 'Server error',
              fieldErrors: [
                FieldError('invalid', 'some error'),
                FieldError('unknown', 'another unknown error'),
              ],
            ),
            localizations),
        equals(localizations.unknownServerValidationError),
      );
    });

    group('password errors', () {
      test('properly formats a single error', () {
        expect(
          createLocalizedErrorMessage(
            const ServerErrorMessage(
              fieldErrors: [
                FieldError('password', 'INSUFFICIENT_SPECIAL'),
              ],
            ),
            localizations,
          ),
          equals(localizations.passwordServerErrorMessage(
              localizations.insufficientSpecialPassword)),
        );
      });

      test('passes through an unknown error', () {
        expect(
          createLocalizedErrorMessage(
            const ServerErrorMessage(
              fieldErrors: [
                FieldError('password', 'unknown error code'),
              ],
            ),
            localizations,
          ),
          equals(
              localizations.passwordServerErrorMessage('unknown error code')),
        );
      });

      test('properly formats multiple errors', () {
        expect(
          createLocalizedErrorMessage(
            const ServerErrorMessage(
              fieldErrors: [
                FieldError('password', 'INSUFFICIENT_SPECIAL'),
                FieldError('password', 'TOO_SHORT'),
              ],
            ),
            localizations,
          ),
          equals(localizations.passwordServerErrorMessage(
              '${localizations.insufficientSpecialPassword}${localizations.errorListJoin}${localizations.tooShortPassword}')),
        );
      });

      test('properly formats multiple unknown', () {
        expect(
          createLocalizedErrorMessage(
            const ServerErrorMessage(
              fieldErrors: [
                FieldError('password', 'invalid error code'),
                FieldError('password', 'TOO_SHORT'),
              ],
            ),
            localizations,
          ),
          equals(localizations.passwordServerErrorMessage(
              'invalid error code${localizations.errorListJoin}${localizations.tooShortPassword}')),
        );
      });

      test('properly formats all errors at once', () {
        final expected = [
          localizations.insufficientSpecialPassword,
          localizations.tooShortPassword,
          localizations.tooLongPassword,
          localizations.insufficientDigitPassword,
          localizations.insufficientUpperCasePassword,
          localizations.insufficientLowerCasePassword,
          localizations.illegalWhiteSpacePassword,
          localizations.illegalAlphabeticalSequencePassword,
          localizations.illegalNumericalSequencePassword,
        ].join(localizations.errorListJoin);
        expect(
          createLocalizedErrorMessage(
            const ServerErrorMessage(
              fieldErrors: [
                FieldError('password', 'INSUFFICIENT_SPECIAL'),
                // Yes, this makes no sense, but this is a test
                FieldError('password', 'TOO_SHORT'),
                FieldError('password', 'TOO_LONG'),
                FieldError('password', 'INSUFFICIENT_DIGIT'),
                FieldError('password', 'INSUFFICIENT_UPPERCASE'),
                FieldError('password', 'INSUFFICIENT_LOWERCASE'),
                FieldError('password', 'ILLEGAL_WHITESPACE'),
                FieldError('password', 'ILLEGAL_ALPHABETICAL_SEQUENCE'),
                FieldError('password', 'ILLEGAL_NUMERICAL_SEQUENCE'),
              ],
            ),
            localizations,
          ),
          equals(localizations.passwordServerErrorMessage(expected)),
        );
      });
    });

    group('email errors', () {
      test('properly formats a single error', () {
        expect(
          createLocalizedErrorMessage(
            const ServerErrorMessage(
              fieldErrors: [
                FieldError('email', 'must be a well-formed email address'),
              ],
            ),
            localizations,
          ),
          equals(localizations.emailServerErrorMessage(
              localizations.emailFormatServerErrorMessage)),
        );
      });

      test('properly formats multiple errors', () {
        expect(
          createLocalizedErrorMessage(
            const ServerErrorMessage(
              fieldErrors: [
                FieldError('email', 'must be a well-formed email address'),
                FieldError('email', 'size must be between 5 and 254'),
              ],
            ),
            localizations,
          ),
          equals(localizations.emailServerErrorMessage(
              '${localizations.emailFormatServerErrorMessage}${localizations.errorListJoin}${localizations.emailLengthServerErrorMessage}')),
        );
      });
    });
  });

  group('isValidEmail', () {
    test('accepts valid emails', () {
      expect(isValidEmail('example@subdomain.example.com'), isTrue);
    });
  });
}
