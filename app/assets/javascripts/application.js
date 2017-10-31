// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require materialize-sprockets
//= require rails-ujs
//= require turbolinks
//= require keyboard/jquery.keyboard.min
//= require_tree .

/* VIRTUAL KEYBOARD DEMO - https://github.com/Mottie/Keyboard */
$(function() {

    // text that is typed when when pressing the
    // keyboard icon (actual code using .typeIn()
    // is at the bottom of this code block
    var simulateTyping = "Hello World!!1\b <3";

    // create a new language (love, awww) by copying the english language
    // file. we're doing this just for this demo, so we can add "<3" to the
    // combo regex
    $.keyboard.language.love = $.extend($.keyboard.language.en);

    $('.key').keyboard({
        language: ['love'],
        rtl: false,
        layout: 'qwerty',
        customLayout: {
            'default': [
                'd e f a u l t',
                '{meta1} {meta2} {accept} {cancel}'
            ],
            'meta1': [
                'm y m e t a 1',
                '{meta1} {meta2} {accept} {cancel}'
            ],
            'meta2': [
                'M Y M E T A 2',
                '{meta1} {meta2} {accept} {cancel}'
            ]
        },
        position: {
            of: null,
            my: 'center top',
            at: 'center top',
            at2: 'center bottom'
        },
        reposition: true,
        usePreview: false,
        alwaysOpen: false,
        initialFocus: true,
        noFocus: false,
        stayOpen: false,
        userClosed: false,
        ignoreEsc: false,
        display: {
            'meta1': '\u2666',
            'meta2': '\u2665',
            'a': '\u2714:Accept (Shift-Enter)',
            'accept': 'Accept:Accept (Shift-Enter)',
            'alt': 'AltGr:Alternate Graphemes',
            'b': '\u2190:Backspace',
            'bksp': 'Bksp:Backspace',
            'c': '\u2716:Cancel (Esc)',
            'cancel': 'Cancel:Cancel (Esc)',
            'clear': 'C:Clear',
            'combo': '\u00f6:Toggle Combo Keys',
            'dec': '.:Decimal',
            'e': '\u21b5:Enter',
            'empty': '\u00a0',
            'enter': 'Enter:Enter',
            'left': '\u2190',
            'lock': '\u21ea Lock:Caps Lock',
            'next': 'Next \u21e8',
            'prev': '\u21e6 Prev',
            'right': '\u2192',
            's': '\u21e7:Shift',
            'shift': 'Shift:Shift',
            'sign': '\u00b1:Change Sign',
            'space': '\u00a0:Space',
            't': '\u21e5:Tab',
            'tab': '\u21e5 Tab:Tab',
            'toggle': ' ',

            'valid': 'valid',
            'invalid': 'invalid',
            'active': 'active',
            'disabled': 'disabled'

        },
        wheelMessage: 'Use mousewheel to see other keys',
        css: {
            input: 'ui-widget-content ui-corner-all',
            container: 'ui-widget-content ui-widget ui-corner-all ui-helper-clearfix',
            popup: '',
            buttonDefault: 'ui-state-default ui-corner-all',
            buttonHover: 'ui-state-hover',
            buttonAction: 'ui-state-active',
            buttonActive: 'ui-state-active',
            buttonDisabled: 'ui-state-disabled',
            buttonEmpty: 'ui-keyboard-empty'
        },
        autoAccept: true,
        autoAcceptOnEsc: true,
        lockInput: false,
        restrictInput: false,
        restrictInclude: '',
        acceptValid: true,
        autoAcceptOnValid: true,
        cancelClose: true,
        tabNavigation: false,
        enterNavigation: false,
        enterMod: 'altKey',
        stopAtEnd: true,
        appendLocally: false,
        appendTo: 'body',
        stickyShift: true,
        preventPaste: false,
        caretToEnd: false,
        scrollAdjustment: 10,
        maxLength: false,
        maxInsert: true,
        repeatDelay: 500,
        repeatRate: 20,
        resetDefault: false,
        openOn: 'focus',
        keyBinding: 'mousedown touchstart',
        useWheel: true,
        useCombos: true,
        combos: {
            '<': { 3: '\u2665' }, // turn <3 into ♥ - change regex below
            'a': { e: "\u00e6" }, // ae ligature
            'A': { E: "\u00c6" },
            'o': { e: "\u0153" }, // oe ligature
            'O': { E: "\u0152" }
        },
        initialized: function(e, keyboard, el) {},
        beforeVisible: function(e, keyboard, el) {},
        visible: function(e, keyboard, el) {},
        beforeInsert: function(e, keyboard, el, textToAdd) { return textToAdd; },
        change: function(e, keyboard, el) {},
        beforeClose: function(e, keyboard, el, accepted) {},
        accepted: function(e, keyboard, el) {},
        canceled: function(e, keyboard, el) {},
        restricted: function(e, keyboard, el) {},
        hidden: function(e, keyboard, el) {},
        switchInput: function(keyboard, goToNext, isAccepted) {},
        validate: function(keyboard, value, isClosing) {
            return true;
        }

    })
        .addTyping({
            showTyping: true,
            delay: 250
        });

    $('.keypswd').keyboard({
        language: ['love'],
        rtl: false,
        layout: 'qwerty',
        customLayout: {
            'default': [
                'd e f a u l t',
                '{meta1} {meta2} {accept} {cancel}'
            ],
            'meta1': [
                'm y m e t a 1',
                '{meta1} {meta2} {accept} {cancel}'
            ],
            'meta2': [
                'M Y M E T A 2',
                '{meta1} {meta2} {accept} {cancel}'
            ]
        },
        position: {
            of: null,
            my: 'center top',
            at: 'center top',
            at2: 'center bottom'
        },
        reposition: true,
        usePreview: true,
        alwaysOpen: false,
        initialFocus: true,
        noFocus: false,
        stayOpen: false,
        userClosed: false,
        ignoreEsc: false,
        display: {
            'meta1': '\u2666',
            'meta2': '\u2665',
            'a': '\u2714:Accept (Shift-Enter)',
            'accept': 'Accept:Accept (Shift-Enter)',
            'alt': 'AltGr:Alternate Graphemes',
            'b': '\u2190:Backspace',
            'bksp': 'Bksp:Backspace',
            'c': '\u2716:Cancel (Esc)',
            'cancel': 'Cancel:Cancel (Esc)',
            'clear': 'C:Clear',
            'combo': '\u00f6:Toggle Combo Keys',
            'dec': '.:Decimal',
            'e': '\u21b5:Enter',
            'empty': '\u00a0',
            'enter': 'Enter:Enter',
            'left': '\u2190',
            'lock': '\u21ea Lock:Caps Lock',
            'next': 'Next \u21e8',
            'prev': '\u21e6 Prev',
            'right': '\u2192',
            's': '\u21e7:Shift',
            'shift': 'Shift:Shift',
            'sign': '\u00b1:Change Sign',
            'space': '\u00a0:Space',
            't': '\u21e5:Tab',
            'tab': '\u21e5 Tab:Tab',
            'toggle': ' ',

            'valid': 'valid',
            'invalid': 'invalid',
            'active': 'active',
            'disabled': 'disabled'

        },
        wheelMessage: 'Use mousewheel to see other keys',
        css: {
            input: 'ui-widget-content ui-corner-all',
            container: 'ui-widget-content ui-widget ui-corner-all ui-helper-clearfix',
            popup: '',
            buttonDefault: 'ui-state-default ui-corner-all',
            buttonHover: 'ui-state-hover',
            buttonAction: 'ui-state-active',
            buttonActive: 'ui-state-active',
            buttonDisabled: 'ui-state-disabled',
            buttonEmpty: 'ui-keyboard-empty'
        },
        autoAccept: true,
        autoAcceptOnEsc: true,
        lockInput: true,
        restrictInput: false,
        restrictInclude: '',
        acceptValid: true,
        autoAcceptOnValid: true,
        cancelClose: true,
        tabNavigation: false,
        enterNavigation: false,
        enterMod: 'altKey',
        stopAtEnd: true,
        appendLocally: false,
        appendTo: 'body',
        stickyShift: true,
        preventPaste: true,
        caretToEnd: false,
        scrollAdjustment: 10,
        maxLength: false,
        maxInsert: true,
        repeatDelay: 500,
        repeatRate: 20,
        resetDefault: false,
        openOn: 'focus',
        keyBinding: 'mousedown touchstart',
        useWheel: true,
        useCombos: true,
        combos: {
            '<': { 3: '\u2665' }, // turn <3 into ♥ - change regex below
            'a': { e: "\u00e6" }, // ae ligature
            'A': { E: "\u00c6" },
            'o': { e: "\u0153" }, // oe ligature
            'O': { E: "\u0152" }
        },
        initialized: function(e, keyboard, el) {},
        beforeVisible: function(e, keyboard, el) {},
        visible: function(e, keyboard, el) {},
        beforeInsert: function(e, keyboard, el, textToAdd) { return textToAdd; },
        change: function(e, keyboard, el) {},
        beforeClose: function(e, keyboard, el, accepted) {},
        accepted: function(e, keyboard, el) {},
        canceled: function(e, keyboard, el) {},
        restricted: function(e, keyboard, el) {},
        hidden: function(e, keyboard, el) {},
        switchInput: function(keyboard, goToNext, isAccepted) {},
        validate: function(keyboard, value, isClosing) {
            return true;
        }

    })
        .addTyping({
            showTyping: true,
            delay: 250
        });


    /* Combos Regex -
        You could change $.keyboard.comboRegex so that it applies to all
        keyboards, but if a specific layout language has a comboRegex defined,
        it has precidence over this setting. This regex is used to match combos
        to combine, the first part looks for the accent/letter and the second
        part matches the following letter so lets say you want to do something
        crazy like turn "<3" into a heart. Add this to the
        combos '<' : { 3: "\u2665" } and add a comma to the end if needed.
        Then change the regex to this: /([<`\'~\^\"ao])([a-z3])/mig;
                                             ( first part  )( 2nd  )  */
    $.keyboard.language.love.comboRegex = /([<`\'~\^\"ao])([a-z3])/mig;

    /* if you look close at the regex, all that was added was "<" to the
      beginning of the first part; some characters need to be escaped with a
      backslash in front because they mean something else in regex. The
      second part has a 3 added after the 'a-z', so that should cover both
      parts :P */

    // Typing Extension
    $('#icon').click(function() {
        var kb = $('#keyboard').getkeyboard();
        // typeIn( text, delay, callback );
        kb.reveal().typeIn(simulateTyping, 500, function() {
            // do something after text is added
            // kb.accept();
        });
    });

});

