= Installation

See public/install.html for setup instructions.

= Timezones

You MUST export the environment variable TZ=UTC, or else the article dates
and times will be invalid.

This would not be needed if rails used UTC for everything, but
unfortunately it doesn't... eg: action_view/helpers/date_helper.rb uses
Time::now instead of Timer::now.utc, and Time::mktime instead of
Time::utc.

XXX oh, we can't depend on the rails helpers at all, because they don't
    translate the time from UTC (assuming the TZ env var is correctly
    set) to site time, you've to roll our own, or monkey patch rails :/

= License

Mephisto is distributed under the same license as Ruby on Rails. See
http://www.opensource.org/licenses/mit-license.php
