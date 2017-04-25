(function($) {

    $.widget("ui.ebdatetimeselector", {
        options: {
            readonly: false,
            minutesIncrement: 15,
            ebDatetimeSelectorControlToUpdateOnChange: ''
        },
        _init: function() {
            this.element.hide();
            this.id = this.element.attr("id");
            this.container = $('<div class="ui-helper-clearfix ui-widget"></div>').insertAfter(this.element);
            this.datetextbox = $("<input id='" + this.id + "__date' type='text' style='width:80px;'></input>").appendTo(this.container);
            this.hoursdropdown = $("<select id='" + this.id + "__hour' type='text' style='margin-left:5px;'><option>01</option><option>02</option><option>03</option><option>04</option><option>05</option><option>06</option><option>07</option><option>08</option><option>09</option><option>10</option><option>11</option><option>12</option></select>").appendTo(this.container);

            if (this.options.minutesIncrement > 0 && this.options.minutesIncrement < 60) {
                var minutesdropdowntext = "<select id='" + this.id + "__minute' type='text'>";
                var curMinute = 0;
                while (curMinute < 60) {
                    var minutestr = '0' + curMinute;
                    if (minutestr.length > 2) {
                        minutestr = minutestr.substr(minutestr.length - 2, 2);
                    }
                    minutesdropdowntext += "<option>" + minutestr + "</option>";
                    curMinute = curMinute + this.options.minutesIncrement;
                }
                minutesdropdowntext += "</select>";
                this.minutesdropdown = $(minutesdropdowntext).appendTo(this.container);
            }
            else {
                this.minutesdropdown = $("<select id='" + this.id + "__minute' type='text'><option>00</option><option>15</option><option>30</option><option>45</option></select>").appendTo(this.container);
            }

            /*
            if (this.options.minutesIncrement == 15) {
            this.minutesdropdown = $("<select id='" + this.id + "__minute' type='text'><option>00</option><option>15</option><option>30</option><option>45</option></select>").appendTo(this.container);
            }
            else if (this.options.minutesIncrement == 10) {
            this.minutesdropdown = $("<select id='" + this.id + "__minute' type='text'><option>00</option><option>10</option><option>20</option><option>30</option><option>40</option><option>50</option></select>").appendTo(this.container);
            }
            else if (this.options.minutesIncrement == 5) {
            this.minutesdropdown = $("<select id='" + this.id + "__minute' type='text'><option>00</option><option>05</option><option>10</option><option>15</option><option>20</option><option>25</option><option>30</option><option>35</option><option>40</option><option>45</option><option>50</option><option>55</option></select>").appendTo(this.container);
            }
            */

            this.ampmdropdown = $("<select id='" + this.id + "__AMPM' type='text'><option>AM</option><option>PM</option></select>").appendTo(this.container);

            var that = this;

            if (this.element.attr("readonly")) {
                this.options.readonly = true;

                this.datetextbox.attr("disabled", "disabled");
                this.hoursdropdown.attr("disabled", "disabled");
                this.minutesdropdown.attr("disabled", "disabled");
                this.ampmdropdown.attr("disabled", "disabled");
            }
            else {
                this.datetextbox.datepicker({ changeMonth: true, changeYear: true, showOn: 'button', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true });

                this.datetextbox.change(function() { that._updateHiddenDate() });
                this.hoursdropdown.change(function() { that._updateHiddenDate() });
                this.minutesdropdown.change(function() { that._updateHiddenDate() });
                this.ampmdropdown.change(function() { that._updateHiddenDate() });
            }

            that.setShownDate();

            // set dimensions
            //this.container.width(this.element.width() + 1);
        },
        destroy: function() {
            this.element.show();
            this.container.remove();

            if ($.Widget === undefined)
                $.widget.prototype.destroy.apply(this, arguments);
            else {
                $.Widget.prototype.destroy.apply(this, arguments);
                return this;
            }
        },
        setShownDate: function() {
            var inputDateStr = this.element.val();

            var firstSlash = inputDateStr.indexOf("/");
            var secondSlash = inputDateStr.indexOf("/", firstSlash + 1);
            var firstColon = inputDateStr.indexOf(":");
            var secondColon = inputDateStr.indexOf(":", firstColon + 1);

            var tmpyear = inputDateStr.substr(secondSlash + 1, 4);
            var tmpmonth = inputDateStr.substr(0, firstSlash);
            var tmpday = inputDateStr.substr(firstSlash + 1, secondSlash - (firstSlash + 1));
            var tmphours = inputDateStr.substr(firstColon - 2, 2);
            var tmpminutes = inputDateStr.substr(firstColon + 1, 2); ;
            var tmpAMPM = inputDateStr.substr(inputDateStr.length - 2, 2);

            var inputDate = new Date(tmpyear, tmpmonth - 1, tmpday, tmphours, tmpminutes, 0, 0); //Month is zero-based (0-11)

            var hourstr = '0' + inputDate.getHours();
            if (hourstr.length > 2) {
                hourstr = hourstr.substr(hourstr.length - 2, 2);
            }

            var minutestr = '0' + inputDate.getMinutes();
            if (minutestr.length > 2) {
                minutestr = minutestr.substr(minutestr.length - 2, 2);
            }

            var monthOneBased = inputDate.getMonth() + 1; //getMonth is zero-based (0 to 11)
            var monthstr = '0' + monthOneBased; 
            if (monthstr.length > 2) {
                monthstr = monthstr.substr(monthstr.length - 2, 2);
            }

            var daystr = '0' + inputDate.getDate();
            if (daystr.length > 2) {
                daystr = daystr.substr(daystr.length - 2, 2);
            }

            this.hoursdropdown.val(hourstr);
            this.minutesdropdown.val(minutestr);
            this.datetextbox.val(monthstr + "/" + daystr + "/" + inputDate.getFullYear());
            this.ampmdropdown.val(tmpAMPM);
        },
        _updateHiddenDate: function() {
            var outDate = $("#" + this.id + "__date").val() + " " + $("#" + this.id + "__hour").val() + ":" + $("#" + this.id + "__minute").val() + ":00 " + $("#" + this.id + "__AMPM").val();
            this.element.val(outDate);

            if (this.options.ebDatetimeSelectorControlToUpdateOnChange != '') {
                var contolToChange = $('#' + this.options.ebDatetimeSelectorControlToUpdateOnChange);
                contolToChange.val($('#' + this.id).val());
                contolToChange.ebdatetimeselector('setShownDate');
            }
        }
    });

    $.extend($.ui.ebdatetimeselector, {
        defaults: {
            readonly: false,
            minutesIncrement: 15,
            ebDatetimeSelectorControlToUpdateOnChange: ''
        }
    });

})(jQuery);