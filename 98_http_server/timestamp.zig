pub const Timestamp = struct {
    unix_ms: i64 = 0,
    year: u16 = 0,
    month: u8 = 0,
    day: u8 = 0,
    hours: u8 = 0,
    minutes: u8 = 0,
    seconds: u8 = 0,
    month_name: []const u8 = undefined,
    day_name: []const u8 = undefined,
    month_name_array: []const []const u8 = &[_][]const u8{ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" },
    day_name_array: []const []const u8 = &[_][]const u8{ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" },

    pub fn now() !Timestamp {
        var ts = Timestamp{};
        const ms = std.time.milliTimestamp();
        try initFromMs(&ts, ms);
        return ts;
    }

    pub fn milliseconds(ms: i64) !Timestamp {
        var ts = Timestamp{};
        try initFromMs(&ts, ms);
        return ts;
    }

    pub fn isYearLeapYear(self: *Timestamp, year: i64) bool {
        if ((@mod(year, 400) == 0 or @mod(year, 100) != 0) and (@mod(year, 4) == 0)) {
            return true;
        }
        return false;
    }

    pub fn dayOfWeek(ts: *Timestamp) []const u8 {
        const t: [12]u8 = .{ 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 };
        const d = ts.day;
        const m = ts.month;
        const y = if (m < 3) ts.year - 1 else ts.year;
        const i: u32 = (y + y / 4 - y / 100 + y / 400 + t[m - 1] + d) % 7;
        // std.debug.print("dayOfWeek: i={}\n", .{i});
        return ts.day_name_array[i];
    }

    fn initFromMs(ts: *Timestamp, ms: i64) !void {
        if (ms < 0) return error.BadValue;
        const base_days_per_month = [_]i64{
            31, // January
            28, // February (29 days on leap year)
            31, // March
            30, // April
            31, // May
            30, // June
            31, // July
            31, // August
            30, // September
            31, // October
            30, // November
            31, // December
        };

        // std.debug.print("\n", .{});
        const days = @divFloor(ms, std.time.ms_per_day);
        // std.debug.print("days={}\n", .{days});
        var year0 = @floatToInt(i64, @intToFloat(f32, days) / 365.25);
        // std.debug.print("year0={}\n", .{year0});
        // var days_remaining = days - @floatToInt(i64, @intToFloat(f32, year0) * 365.25);
        // above formula doesn't work... brute force loop subtract days in each year
        var days_remaining = days;
        var y: i64 = 0;
        while (y < year0) : (y += 1) {
            if (ts.isYearLeapYear(1970 + y)) days_remaining -= 366 else days_remaining -= 365;
        }
        var month0: i64 = 0;
        for (base_days_per_month) |value, i| {
            // add one day to february if this year is a leap year
            const year = 1970 + year0;
            const days_per_month = if (i == 1 and ts.isYearLeapYear(year)) value + 1 else value;
            // std.debug.print("days_per_month[{}]={}\n", .{ i, days_per_month });
            if (days_per_month > days_remaining) break;
            days_remaining -= days_per_month;
            month0 += 1;
        }
        // std.debug.print("month0={}\n", .{month0});
        const day0: i64 = days_remaining;
        // std.debug.print("day0={}\n", .{day0});
        const hours = @divFloor(ms - (days * std.time.ms_per_day), std.time.ms_per_hour);
        // std.debug.print("hours={}\n", .{hours});
        const minutes = @divFloor(ms - (days * std.time.ms_per_day) - (hours * std.time.ms_per_hour), std.time.ms_per_min);
        // std.debug.print("minutes={}\n", .{minutes});
        const seconds = @divFloor(ms - (days * std.time.ms_per_day) - (hours * std.time.ms_per_hour) - (minutes * std.time.ms_per_min), std.time.ms_per_s);
        // std.debug.print("seconds={}\n", .{seconds});

        ts.unix_ms = ms;
        ts.year = 1970 + @intCast(u16, year0);
        ts.month = @intCast(u8, month0) + 1;
        ts.day = @intCast(u8, day0) + 1;
        ts.hours = @intCast(u8, hours);
        ts.minutes = @intCast(u8, minutes);
        ts.seconds = @intCast(u8, seconds);
        ts.month_name = ts.month_name_array[@intCast(usize, month0)];
        ts.day_name = ts.dayOfWeek();
    }

    pub fn asctime(ts: *Timestamp, buffer: []u8) ![]u8 {
        return std.fmt.bufPrint(buffer, "{}, {d:0>2} {} {d:0>4} {d:0>2}:{d:0>2}:{d:0>2} GMT", .{
            ts.day_name,
            ts.day,
            ts.month_name,
            ts.year,
            ts.hours,
            ts.minutes,
            ts.seconds,
        });
    }
};

test "leap year calculation" {
    const expect = std.testing.expect;
    var ts = try Timestamp.now();
    expect(ts.isYearLeapYear(1900) == false);
    expect(ts.isYearLeapYear(1992) == true);
    expect(ts.isYearLeapYear(2000) == true);
    expect(ts.isYearLeapYear(2001) == false);
    expect(ts.isYearLeapYear(2019) == false);
    expect(ts.isYearLeapYear(2020) == true);
    expect(ts.isYearLeapYear(2021) == false);
    expect(ts.isYearLeapYear(2024) == true);
    expect(ts.isYearLeapYear(2100) == false);
    expect(ts.isYearLeapYear(2400) == true);
}

test "unixtimestamp 0 is 1970-01-01T00:00:00 UTC" {
    const expect = std.testing.expect;
    const ms: i64 = 0;
    var ts = try Timestamp.milliseconds(ms);
    expect(ts.year == 1970);
    expect(ts.month == 1);
    expect(ts.day == 1);
    expect(ts.hours == 0);
    expect(ts.minutes == 0);
    expect(ts.seconds == 0);
    var buffer: [32]u8 = undefined;
    const asctime: []u8 = try ts.asctime(buffer[0..]);
    std.debug.print("asctime={}\n", .{asctime});
    expect(std.mem.eql(u8, asctime, "Thu, 01 Jan 1970 00:00:00 GMT"));
}

// test "unixtimestamp -2208988800 is 1900-01-01T00:00:00 (UTC)" {
//     const expect = std.testing.expect;
//     const ms: i64 = -2208988800 * std.time.ms_per_s;
//     var ts = Timestamp.milliseconds(ms);
//     expect(ts.year == 1900);
//     expect(ts.month == 1);
//     expect(ts.day == 1);
// }

// test "timestamp -3304460700 is 1865-04-14T22:15 (UTC)" {
//     // assassination of president abraham lincoln
//     const expect = std.testing.expect;
//     const ms: i64 = -3304460700 * std.time.ms_per_s;
//     var ts = Timestamp.milliseconds(ms);
//     expect(ts.year == 1865);
//     expect(ts.month == 4);
//     expect(ts.day == 14);
// }

test "unix time 1000000000 is 2001-09-09T01:46:40 UTC" {
    const expect = std.testing.expect;
    const ms: i64 = 1000000000 * std.time.ms_per_s;
    var ts = try Timestamp.milliseconds(ms);
    expect(ts.year == 2001);
    expect(ts.month == 9);
    expect(ts.day == 9);
    expect(ts.hours == 1);
    expect(ts.minutes == 46);
    expect(ts.seconds == 40);
    expect(std.mem.eql(u8, ts.day_name, "Sun"));
    var buffer: [32]u8 = undefined;
    const asctime: []u8 = try ts.asctime(buffer[0..]);
    std.debug.print("asctime={}\n", .{asctime});
    expect(std.mem.eql(u8, asctime, "Sun, 09 Sep 2001 01:46:40 GMT"));
}

test "unix time 1234567890 is 2009-02-13T23:31:30 UTC" {
    const expect = std.testing.expect;
    const ms: i64 = 1234567890 * std.time.ms_per_s;
    var ts = try Timestamp.milliseconds(ms);
    expect(ts.year == 2009);
    expect(ts.month == 2);
    expect(ts.day == 13);
    expect(ts.hours == 23);
    expect(ts.minutes == 31);
    expect(ts.seconds == 30);
    expect(std.mem.eql(u8, ts.day_name, "Fri"));
    var buffer: [32]u8 = undefined;
    const asctime: []u8 = try ts.asctime(buffer[0..]);
    std.debug.print("asctime={}\n", .{asctime});
    expect(std.mem.eql(u8, asctime, "Fri, 13 Feb 2009 23:31:30 GMT"));
}

test "unix time 1600000000 is 2020-09-13T12:26:40 UTC" {
    const expect = std.testing.expect;
    const ms: i64 = 1600000000 * std.time.ms_per_s;
    var ts = try Timestamp.milliseconds(ms);
    expect(ts.year == 2020);
    expect(ts.month == 9);
    expect(ts.day == 13);
    expect(ts.hours == 12);
    expect(ts.minutes == 26);
    expect(ts.seconds == 40);
    expect(std.mem.eql(u8, ts.day_name, "Sun"));
    var buffer: [32]u8 = undefined;
    const asctime: []u8 = try ts.asctime(buffer[0..]);
    std.debug.print("asctime={}\n", .{asctime});
    expect(std.mem.eql(u8, asctime, "Sun, 13 Sep 2020 12:26:40 GMT"));
}

// imports
const std = @import("std");
