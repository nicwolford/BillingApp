(function($) {

    $.widget("ui.ebtextarea", {
        options: {
            readonly: false,
            minHeight: 50,
            maxLength: 400
        },
        _init: function() {
            this.id = this.element.attr("id");

            if (this.element.attr("readonly")) {
                this.options.readonly = true;
            }
            else {
                this.options.readonly = false;
                var curLen = this.element[0].value.length;
                $("<br style='line-height:0px;'/><span id='" + this.id + "_TextLengthMessage' class='ats-customforms_textlengthmessage'>You have " + (this.options.maxLength - curLen) + " characters remaining</span>").insertAfter(this.element);
            }

            var that = this;

            this.element.css("padding-top", 0).css("padding-bottom", 0);
            this._RegisterEvents();
            this.triggerResizeTextArea();

        },
        destroy: function() {
            if ($.Widget === undefined)
                $.widget.prototype.destroy.apply(this, arguments);
            else {
                $.Widget.prototype.destroy.apply(this, arguments);
                return this;
            }
        },
        _RegisterEvents: function() {
            var that = this;
            that.element.bind('keyup', that._ResizeTextarea);
        },
        _ResizeTextarea: function(e) {
            var minHeight = $.data(this, 'ebtextarea').options.minHeight;
            var maxLength = $.data(this, 'ebtextarea').options.maxLength;
            var readonly = $.data(this, 'ebtextarea').options.readonly;
            var hCheck = !($.browser.msie || $.browser.opera);
            // event or initialize element?
            e = e.target || e;

            // find content length and box width
            var vlen = e.value.length, ewidth = e.offsetWidth;
            if (vlen != e.valLength || ewidth != e.boxWidth) {

                //if (hCheck && (vlen < e.valLength || ewidth != e.boxWidth)) e.style.height = "0px";
                var h = Math.max(minHeight, e.scrollHeight);

                e.style.overflow = (e.scrollHeight > h ? "auto" : "hidden");
                e.style.height = h + "px";

                e.valLength = vlen;
                e.boxWidth = ewidth;
            }

            if (!readonly) {
                if ((maxLength - vlen) < 0) {
                    $('#' + this.id + '_TextLengthMessage').addClass('ats-customforms_textlengthmessage-error');
                    $('#' + this.id + '_TextLengthMessage').html("You have entered " + (0 - (maxLength - vlen)) + ' characters too many');
                } else {
                    $('#' + this.id + '_TextLengthMessage').removeClass('ats-customforms_textlengthmessage-error');
                    $('#' + this.id + '_TextLengthMessage').html('You have ' + (maxLength - vlen) + ' characters remaining');
                }
            }

            return true;
        },
        triggerResizeTextArea: function() {
            var that = this;
            that.element.trigger('keyup');
        },
        insertAtCursor: function(textToInsert){
            var that = this;
            
            //IE support
            if (document.selection) {
                that.element.focus();
                sel = document.selection.createRange();
                sel.text = textToInsert;
            }
            //MOZILLA/NETSCAPE support
            else if (that.element[0].selectionStart || that.element[0].selectionStart == '0') {
                var startPos = that.element[0].selectionStart;
                var endPos = that.element[0].selectionEnd;
               that.element[0].value = that.element[0].value.substring(0, startPos)
                  + textToInsert
                  + that.element[0].value.substring(endPos, that.element[0].value.length);
            } else {
                that.element[0].value += textToInsert;
            }
        }
    });

    $.extend($.ui.ebdatetimeselector, {
        defaults: {
            readonly: false,
            minHeight: 50,
            maxLength: 400
        }
    });

})(jQuery);