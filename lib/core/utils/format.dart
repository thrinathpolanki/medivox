const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const weekdayShort = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

String formatTime(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

const weekdayLong = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];

String formatDayHeading(DateTime d) =>
    '${weekdayLong[d.weekday - 1]}, ${formatDate(d)}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
