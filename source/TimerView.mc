//
// Copyright Fernando Mercado <fernando.mercado@gmail.com>
//
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

//! Show the three timer callback counts
class TimerView extends WatchUi.View {
    private var _timer1 as Timer.Timer?;
    private var _count1 as Number = 0;
    private var _distance as Number = 0;
    private var _running = false;
    private var _progressBar;
    private var _progress;
    private var _label;

    //! Constructor
    public function initialize() {
        WatchUi.View.initialize();
    }

    //! Callback for timer 1
    public function callback1() as Void {
        _count1++;
        _distance = _count1 * 22;
        WatchUi.requestUpdate();
    }

    public function reset() as Void {
        _count1 = 0;
    }

    //! Load your resources here
    //! @param dc Device context
    public function onLayout(dc as Dc) as Void {
        // var timer1 = new Timer.Timer();
        // timer1.start(method(:callback1), 500, true);
        // _timer1 = timer1;
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var string = "Time:";
        var y = dc.getHeight() / 6;
        dc.drawText((dc.getWidth() / 2), ( y*1), Graphics.FONT_MEDIUM, string, Graphics.TEXT_JUSTIFY_CENTER);
        string = "" + _count1 / 16 + " (s)";
        dc.drawText((dc.getWidth() / 2), y*2, Graphics.FONT_MEDIUM, string, Graphics.TEXT_JUSTIFY_CENTER);
        string = "Distance:";
        dc.drawText((dc.getWidth() / 2), y*3, Graphics.FONT_MEDIUM, string, Graphics.TEXT_JUSTIFY_CENTER);
        string = "" + _distance + " (m)";
        dc.drawText((dc.getWidth() / 2), y*4, Graphics.FONT_LARGE, string, Graphics.TEXT_JUSTIFY_CENTER);

    }
    
     public function startTimer() as Void {
        var timer1 = new Timer.Timer();
        timer1.start(method(:callback1), 63, true);
        _timer1 = timer1;
        _count1 = 0;
        _running = true;
        
    }
    //! Stop the first timer
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


class ProgressDelegate extends WatchUi.BehaviorDelegate {
    private var _callback as Method() as Void;

    //! Constructor
    //! @param callback Callback function
    public function initialize(callback as Method() as Void) {
        BehaviorDelegate.initialize();
        _callback = callback;
    }

    //! Handle back behavior
    //! @return true if handled, false otherwise
    public function onBack() as Boolean {
        _callback.invoke();
        return true;
    }
}

//! Creates and updates the progress bar
class InputDelegate extends WatchUi.BehaviorDelegate {

    private var _progressBar as ProgressBar?;
    private var _timer as Timer.Timer?;
    private var _count as Number = 0;

    //! Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
    }

    //! On a select event, create a progress bar
    //! @return true if handled, false otherwise
    public function onSelect() as Boolean {
        if (_timer == null) {
            _timer = new Timer.Timer();
        }
        _count = 0;

        _progressBar = new WatchUi.ProgressBar("Processing", null);
        WatchUi.pushView(_progressBar, new $.ProgressDelegate(method(:stopTimer)), WatchUi.SLIDE_DOWN);

        (_timer as Timer.Timer).start(method(:timerCallback), 1000, true);
        return true;
    }

    //! Stop the timer
    public function stopTimer() as Void {
        var timer = _timer;
        if (timer != null) {
            timer.stop();
        }
    }

    //! Update the progress bar every second
    public function timerCallback() as Void {
        _count++;

        var progressBar = _progressBar;
        if (progressBar != null) {
            if (_count > 17) {
                var timer = _timer;
                if (timer != null) {
                    timer.stop();
                }
                WatchUi.popView(WatchUi.SLIDE_UP);
            } else if (_count > 15) {
                progressBar.setDisplayString("Complete");
            } else if (_count > 5) {
                progressBar.setProgress(((_count - 5) * 10).toFloat());
            }
        }
    }
}