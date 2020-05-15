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
import 'package:ox_coi/src/customer/customer_delegate_change_notifier.dart';
import 'package:ox_coi/src/dynamic_screen/dynamic_screen.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/platform/system_interaction.dart';
import 'package:provider/provider.dart';

class PageTextFieldComponent extends PageBaseComponent {
  final DynamicScreenTextfieldModel model;

  static String _textFieldValue = "";
  final _textController = TextEditingController(text: _textFieldValue);
  final _focusNode = FocusNode();

  PageTextFieldComponent({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customerDelegate = Provider.of<DynamicScreenCustomerDelegate>(context, listen: false);
    final decoration = InputDecoration(
      labelText: model.label.stringValue,
      helperText: model.placeholder.stringValue
    );

    return Consumer<CustomerDelegateChangeNotifier>(
      builder: (context, changeNotifier, child) {
        return Padding(
          padding: model.padding.edgeInsetsValue,
          child: TextField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.done,
            decoration: decoration,
            controller: _textController,
            focusNode: _focusNode,
            key: Key(L.getKey(L.type)),
            onChanged: (value) {
              _textFieldValue = value;
              print("[Textfield Changed] Value: $_textFieldValue");
            },
            onEditingComplete: () {
              unFocus(context);
              _textController.text = _textFieldValue;
              customerDelegate.textfieldEditingCompleteAsync(context: context, value: _textFieldValue);
              print("[Textfield Edit Complete] Value: $_textFieldValue");
            },
          ),
        );
      }
    );
  }
}