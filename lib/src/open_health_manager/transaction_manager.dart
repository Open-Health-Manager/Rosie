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

import 'package:fhir/r4.dart';
import 'open_health_manager.dart';

class TransactionManager {
  Bundle? _updateBatch;

  bool activeBatch() {
    return (_updateBatch != null);
  }

  createUpdateBatch() {
    if (_updateBatch != null) {}
    _updateBatch = Bundle(type: BundleType.transaction);
  }

  postCurrentUpdateBatch(OpenHealthManager manager) async {
    if (_updateBatch != null) {
      await manager.postTransaction(_updateBatch!);
      _updateBatch = null;
    }
  }

  addEntryToUpdateBatch(Resource theResource) {
    if (_updateBatch == null) {
      createUpdateBatch();
    }
    BundleEntry theEntry = BundleEntry(
      resource: theResource,
      request: BundleRequest(
        method: (theResource.id == null)
            ? BundleRequestMethod.post
            : BundleRequestMethod.put,
        url: FhirUri(
          theResource.resourceTypeString! +
              ((theResource.id == null || theResource.id!.value == null)
                  ? ""
                  : "/${theResource.id!.value!}"),
        ),
      ),
    );
    List<BundleEntry>? updatedEntryList = _updateBatch!.entry;
    if (updatedEntryList == null) {
      updatedEntryList = <BundleEntry>[theEntry];
    } else {
      updatedEntryList.add(theEntry);
    }

    _updateBatch = _updateBatch!.copyWith(entry: updatedEntryList);
  }
}
