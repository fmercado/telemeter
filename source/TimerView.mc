//
// Copyright Fernando Mercado <fernando.mercado@gmail.com>
//
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;
import Toybox.System;

//! Show the three timer callback counts
class TimerView extends WatchUi.View {
    private var _timer1 as Timer.Timer?;
    private var _count1 as Number = 0;
    private var _distance as Number = 0;
    private var _running = false;
    private var _distance_units;
    private var _distance_unit_label;

    private var updates_second = 8;
    private var timer_interval = 1000/updates_second;
    private var speed_sound_interval;

    //! Constructor
    public function initialize() {

        _distance_units = System.getDeviceSettings().distanceUnits;

        if (_distance_units == 0) {
            _distance_unit_label = "m";
            speed_sound_interval = 340/updates_second;
        } else {
            _distance_unit_label = "f";
            speed_sound_interval = 1125/updates_second;
        }

        WatchUi.View.initialize();
    }

    //! Callback for timer 1
    public function callback1() as Void {
        _count1++;
        // Calculate the actual distance so far
        _distance = _count1 * speed_sound_interval;


        WatchUi.requestUpdate();
    }

    public function reset() as Void {
        // Reset the clicks counted
        _count1 = 0;
    }

    //! Load your resources here
    //! @param dc Device context
    public function onLayout(dc as Dc) as Void {
        
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        // Prepare the canvas 
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var message;

        // After a couple of seconds counting feet we switch to miles
        if (_count1 > 40 and _distance_units == 1) {
            _distance_unit_label = "mi";
            _distance = _distance / 5280.0; 
        }

        self.print_centered(dc, 1, "Time:");
        // Amount o seconds since start
        message = "" + _count1 / updates_second + " (s)";
        self.print_centered(dc, 2, message);

        self.print_centered(dc, 3, "Distance:");
        
        // Show the current distance
        message = "" + _distance + " " + _distance_unit_label;
        self.print_centered(dc, 4, message);
    }
    
    public function print_centered(dc as Dc, row as Number, message as String) as Void {
        var align = Graphics.TEXT_JUSTIFY_CENTER;
        var size = Graphics.FONT_MEDIUM;
        var x = dc.getWidth() / 2;
        var vertical_row = dc.getHeight() / 6;

        dc.drawText(x, vertical_row*row, size, message, align);
    }

    public function startTimer() as Void {
        var timer1 = new Timer.Timer();
        
        // Start the timer
        timer1.start(method(:callback1), timer_interval, true);
        _timer1 = timer1;
        _count1 = 0;
        _running = true;
    }

    public function stopTimer() as Void {
        var timer = _timer1;
        if (_running) {
            timer.stop();
            _running = false;
        } else {
            startTimer();
        }
    }
}
