/*
 * OPEN-XCHANGE legal information
 *
 * All intellectual property rights in the Software are protected by
 * international copyright laws.
 *
 *
 * In some countries OX, OX Open-Xchange and open xchange
 * as well as the corresponding Logos OX Open-Xchange and OX are registered
 * trademarks of the OX Software GmbH group of companies.
 * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 * Instead, you are allowed to use these Logos according to the terms and
 * conditions of the Creative Commons License, Version 2.5, Attribution,
 * Non-commercial, ShareAlike, and the interpretation of the term
 * Non-commercial applicable to the aforementioned license is published
 * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *
 * Please make sure that third-party modules and libraries are used
 * according to their respective licenses.
 *
 * Any modifications to this package must retain all copyright notices
 * of the original copyright holder(s) for the original code used.
 *
 * After any such modifications, the original and derivative code shall remain
 * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 * https://www.open-xchange.com/legal/. The contributing author shall be
 * given Attribution for the derivative code and a license granting use.
 *
 * Copyright (C) 2016-2020 OX Software GmbH
 * Mail: info@open-xchange.com
 *
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 * for more details.
 */

import 'package:flutter/material.dart';
import 'package:ox_coi/src/brandable/brandable_icon.dart';
import 'package:ox_coi/src/navigation/navigatable.dart';
import 'package:ox_coi/src/navigation/navigation.dart';
import 'package:ox_coi/src/brandable/custom_theme.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';

class Search extends SearchDelegate {
  final Function onBuildResults;
  final Function onBuildSuggestion;
  final Function onClose;
  final Function onStart;
  final Navigation _navigation = Navigation();

  Search({@required this.onBuildResults, @required this.onBuildSuggestion, this.onClose, this.onStart});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: AdaptiveIcon(
            icon: IconSource.clear
        ),
        key: Key(keySearchClearIconButton),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    var customTheme = CustomTheme.of(context);
    return theme.copyWith(
      primaryColor: customTheme.surface,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: customTheme.onSurface),
      primaryColorBrightness: customTheme.brightness,
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AdaptiveIcon(
          icon: IconSource.arrowBack
      ),
      key: Key(keySearchReturnIconButton),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return onBuildResults(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return onBuildSuggestion(query);
  }

  show(BuildContext context) {
    if (onStart != null) {
      onStart();
    }
    Navigatable previousNavigatable = _navigation.current;
    _navigation.current = Navigatable(Type.search);
    showSearch(
      context: context,
      delegate: this,
    ).then((value) {
      _navigation.current = previousNavigatable;
      if (onClose != null) {
        onClose();
      }
    });
  }

  bool isSearchActive() {
    return query.isNotEmpty;
  }
}
