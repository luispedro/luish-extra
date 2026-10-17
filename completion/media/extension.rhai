// Completion for audio and video tools, by the command's name.

// ffmpeg's options depend on where they are on the line (an input's or an output's, the codec and the format chosen
// before them) and many are read from the installed ffmpeg, so it has a completer of its own.
sh::completer("ffmpeg", |words, i| {
    import "ffmpeg" as m;
    m::complete(words, i)
});
