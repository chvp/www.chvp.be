+++
title = "Introducing NanoLedger, an Android app for recording PTA transactions on the fly"
[taxonomies]
Tags = ["Android", "PTA", "Emacs"]
+++

In September 2023, I wrote an Android app so I can easily add transactions to my plain text accounting ledger file while on the go.
It was recently [published on F-Droid](https://f-droid.org/en/packages/be.chvp.nanoledger/), so I thought, why not write a blog post about it.
I will go over why I made it, some light technical details, and plans I have for it in the future.

<!-- more -->

## Plain Text Accounting

Before I get into the app itself, maybe a short introduction of plain text accounting (PTA) is in order.
PTA is an ecosystem of programs that all work on the same basic idea.
You record financial transactions in a plain text file (with some structure imposed by the tool you're using), and the tool can generate reports about those transactions.
The three main options in this space are [ledger](https://www.ledger-cli.org/), [hledger](https://hledger.org/) and [beancount](https://beancount.github.io/).
Like all financial tools, the way you use it is tailored to the information you want to get out of it.
If you want a general overview on your personal finances, that's possible.
If you want to use it to generate invoices for clients, that's possible.
If you want to know how much money you spent on cheese in the last year, that's also possible (€ 221.92 for me in 2022).
I will leave further explanation to [others](https://plaintextaccounting.org/), but definitely check it out if you're interested.

## Why I wrote this app

Before NanoLedger, I used [Cone](https://github.com/bradyt/cone).
Unfortunately, the author of Cone has abandoned the app, and I was experiencing some breaking bugs.
When syncing my journal files via Nextcloud, the app just straight up crashes, because it doesn't read the files in a background thread and reading files over Nextcloud does some network calls.
I used Syncthing for a while to sync files, but it used a lot of battery on my phone, so I really wanted to switch to using Nextcloud.

Also, I've been doing PTA for 5 years now, so my journal file has gotten pretty big.
Because the file is read in the foreground the app just hangs while it is reading (or writing) to the file, which is not a nice experience.

So, why not just fork Cone and fix it that way?
Well, Cone is written in Flutter, which I'm not a big fan of.
Besides that, the technical challenge of writing another Android app just seemed like fun to me.
I do consider NanoLedger to be a spritual fork of Cone, given that I definitely was inspired by its functionality while writing NanoLedger.

## Technical details

So what framework to use, if not Flutter?
I tried to keep to the basics, so a simple native app, using the libraries currently recommended.
This means that the app is written in Kotlin, using the Compose framework, with a Model-View-ViewModel architecture.

I wrote the app itself in about a week in my free time (so only evenings and weekend).
It's not that big of an app, but I'm still quite proud of myself that I got this done in a week.
I used my favorite editor, Emacs, configured with [kotlin-language-server](https://github.com/fwcd/kotlin-language-server).
This means no memory-hogging Android Studio.
Most of my friends declare me crazy every time I mention this, but I'm so used to Emacs that I doubt Android Studio would have allowed me to write this app faster.

### Parsing journal files

In fact, most of the time that went into the app, was spent on parsing journal files.
Because the format is mostly about being nice to write, parsing it isn't very easy.
I started out with writing an elegant parser using parser combinators (trying out multiple Kotlin libraries to do so along the way).
It quickly became obvious though that this would be far too slow to actually use in practice.
Depending on the library used, parsing the file took anywhere from multiple seconds up to multiple minutes.
In the end, I replaced all this relatively complicated parsing work with a simple nested while loop that only tries to extract the information I actually need in the app to show transactions.
The one technical consequence of this is that I can't cleanly reconstruct the file based on the parsed transactions, because along the way I throw away comments, directives, secondary dates, ...

## Future plans

While I'm already very happy with it, there are still some improvements possible.
These include but are not limited to
* syntax highlighting of transactions,
* deleting transactions, and
* editing transactions.

Because of the way I parse the journal files, these last two won't be very simple but I have some ideas on how to go about implementing them.

## Closing thoughts

I wrote this app for myself, to fix a problem I was experiencing.
I submitted it to F-Droid because I thought it could be useful for others.
It seems, however, that others were experiencing the same problems, because I noticed that the app had gone live on F-Droid when people started mentioning me on Mastodon.
It was very nice to see such a warm response.
A colleague of mine also started out with PTA because of NanoLedger, which was also quite nice to hear.
All in all, I'm very happy I took the time to write it.

