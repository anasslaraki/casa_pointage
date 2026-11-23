/// Keeps [text] (times, codes) left-to-right when it is embedded in Arabic
/// text, using Unicode isolates.
String ltr(String text) =>
    '${String.fromCharCode(0x2066)}$text${String.fromCharCode(0x2069)}';
