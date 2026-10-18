// PARROT

const std = @import("std");
const print = std.debug.print;

// technically not a u8 since duckai says slices are usize
const N_MAX_CHARS: usize = 32;



pub fn user_input(io: std.Io, s_txt: []u8) ?[]const u8 { // returns arr of chars
    const stdin = std.Io.File.stdin();
    // in the book this line is at the top of the file but
    // i was getting an error and duck.ai told me

    // "A top-level, or container-level, initializer
    // must be known at compile time. But std.Io.File.stdin()
    // obtains the process’s actual standard-input handle,
    //which is only known at runtime—especially on Windows.
    //Therefore Zig tries to evaluate it during compilation and fails."

    // when it's here, it only needs to be evaled if called

    var a_buff: [1024]u8 = undefined;
    var o_reader = stdin.reader(io, &a_buff);
    const s_line = o_reader.interface.takeDelimiterExclusive('\n') catch {
        print("\n\ninput error, toodles.\n\n", .{});
        return null;
    };
    const n_len = if (s_line.len > N_MAX_CHARS) N_MAX_CHARS else s_line.len;

    // n_len - 1 is a magic value bc when i press enter,
    // windows interprets this as \r\n
    // s_line is the slice of the input without \n
    // but the /r messes with the output too so i
    // get rid of that char at the end of the string too
    std.mem.copyForwards(u8, s_txt, s_line[0 .. n_len - 1]);

    return s_txt[0 .. n_len - 1];
}

pub fn parrot_quip(i: *u8) []const u8 {
    if (i.* > 10) {
        i.* = 1;
    }

    switch (i.*) {
        // unicode is supported but that doesn't mean √(ε₀μ₀)^-1 will be translated by windows to
        // mean some garbage like  ΓêÜ(╬╡ΓéÇ╬╝ΓéÇ)^-1, i just need to put the
        // codes (\u{221A}(\u{03B5}\u{2080}\u{03BC}\u{2080}) and itll work
        // it did not, even after successfully running chcp 65001, whatever, i'll use words

        1, 6 => return "the reciprocal of the square root of the product of the vacuum permeability and permittivity constants should have something to do with electricity and magnetism, and it does.",
        2, 7 => return "as long as you're talking to an electrical engineer, they will understand what you mean if you describe light bulbs as having a certain amount of horsepower, probably.",
        3, 8 => return "if your tire pressure was >1EPa, you'd probably die or something. the car insurance ppl still wouldn't care tho.",
        4, 9 => return "where did the k in kinematics come from?",
        5, 10 => return "did y'all see the dude who hit copy paste in matlab, that was hilarious.",
        else => return "quip_bugged",
    }
}

pub fn parrot_speak(input: []const u8, quip: []const u8, i: *u8) void {
    if (i.* > 6) {
        i.* = 1;
    }
    print("\nparrot: ", .{});

    switch (i.*) {
        1 => {
            print("{s} i mean coo coo, {s}", .{ quip, input });
        },
        2 => {
            print("{s} i mean chirp chirp chirp, {s}", .{ quip, input });
        },
        3 => {
            print("{s} i mean SQUAAAAWK, {s}", .{ quip, input });
        },
        4 => {
            print("{s} i mean eeeeuueeeeeuweeeeueeee, {s}", .{ quip, input });
        },
        5 => {
            print("{s} i mean birdBrain.play(bird_sound.aiff), {s}", .{ quip, input });
        },
        else => {
            print("i layed an easter egg, look! i mean, {s}", .{input});
        },
    }
    print("\n", .{});
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = std.heap.page_allocator;

    // allocate 32 ascii chars for user input and free when done
    const s_txt = try gpa.alloc(u8, N_MAX_CHARS);
    defer gpa.free(s_txt); // why is it called gpa???
    // duck ai says this means general purpose allocator, which is silly, allocator is more readable
    // i can do that in the future i suppose

    var i: u8 = 1;
    var iOther: u8 = 1;
    while (true) {
        print("\nuser: ", .{});
        var s_input = user_input(io, s_txt) orelse {
            break;
        };

        // you can't compare strings with ==
        if (std.mem.eql(u8, s_input, "")) s_input = "you real goofy 4 not typing anything gang";

        if (std.mem.eql(u8, s_input, "bye")) {
            print("\nparrot: ok, so you hate me then, smh", .{});
            break;
        }

        var pq: []const u8 = parrot_quip(&i);
        // for the luls
        if (std.mem.eql(u8, s_input, "bro shut up")) pq = "bro, YOU shut up";

        parrot_speak(s_input, pq, &iOther);
        i += 1;
        iOther += 1;

        //print("[{s}], [{s}]\n\n\n", .{ s_input, pq }); debug bc i didn't know about how enter is \r\n on windows
    }
}
