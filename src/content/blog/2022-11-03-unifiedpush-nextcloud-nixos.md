+++
title = "Setting up Nextcloud as a UnifiedPush provider on NixOS"
[taxonomies]
Tags = ["Nix", "NixOS", "Fediverse", "Matrix", "Android"]
+++

I recently set up Nextcloud as a UnifiedPush provider on NixOS. Since others
might want to do the same, I've detailed the process in this blog post. First I
will explain in a nutshell what UnifiedPush is and why anyone would want to use
it, next I will go over the steps required for setting it up.

<!-- more -->
## UnifiedPush

UnifiedPush is used to deliver push notifications to Android devices. It
specifies how servers should talk with push providers, and how apps should talk
with push distributors. The push distributor is the only app keeping open a
connection to the push provider, making this a lot more efficient than every app
that needs push notifications implementing its own polling mechanism. Since
receiving push notifications is the only function of a push distributor, I also
trust it more to do so efficiently. When the push distributor receives a
notification, it distributes it to the corresponding app, which can now react to
the actual notification.

Apps that want to receive push notifications need to register with the push
distributor first. The push distributor will then give the app the information
that the server backend needs to send the push notifications.

Note that nothing about this is Android-specific; one could implement a push
distributor for any sufficiently open platform (in fact, a [D-Bus distributor
specification](https://unifiedpush.org/spec/dbus/) exists). However, since
Android is the most widely-used mobile OS where something like this is possible,
it is the platform where most of the development has happened.

UnifiedPush is a great alternative to Firebase Cloud Messaging (Google's push
notification service). Apps do not need to register with any central authority
and do not need to pay to send push notifications. Users are free to choose
which service their data flows through, and as this post shows, can even
self-host this service. A number of apps already support this service; in my
case I am using [Tusky](https://tusky.app/) (a Mastodon client) and [Element
Android](https://matrix.org/docs/projects/client/element-android/) (a Matrix
client).

## Configuring Nextcloud

### Prerequisites

I assume that you've already set up a Nextcloud instance (using the [NixOS module](https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=services.nextcloud.)). The
module is not that complicated if not. Feel free to steal any part of [my config](https://github.com/chvp/nixos-config/blob/main/modules/services/nextcloud/default.nix).

### NixOS configuration

First, you need to make sure that Nextcloud can load the redis PHP module, that
you have a redis server running and that Nextcloud is configured to use it. Redis
is used as a message broker in this case, so if this part is missing the
communication from the notifying servers will not go through to the devices that
are listening. In addition to redis, you also need to tweak nginx to allow the
long-running requests that are typically used for push notifications.

The configuration for Nextcloud should look like this:

```nix
{
  services.nextcloud = {
    # Your other configuration here
    caching.redis = true;
    extraOptions.redis = {
      host = "127.0.0.1";
      port = 31638;
      dbindex = 0;
      timeout = 1.5;
    };
  };
}
```

Of course, you need to configure redis as well:

```nix
{
  services.redis.servers.nextcloud = {
    enable = true;
    port = 31638;
    bind = "127.0.0.1";
  };
}
```

And finally, you need to make sure you allow long-running requests in nginx:

```nix
{
  services.nginx.virtualHosts."your.nextcloud.hostname".extraConfig = ''
    fastcgi_connect_timeout 10m;
    fastcgi_read_timeout 10m;
    fastcgi_send_timeout 10m;
  '';
}
```

Make sure to switch to the new configuration after making your edits.

### Nextcloud configuration

After setting up Nextcloud itself, you still need to install the ["UnifiedPush
Provider"](https://apps.nextcloud.com/apps/uppush) app. This can be found under
the Multimedia category in the Nextcloud apps admin interface. Note that you can
also manage Nextcloud apps declaratively on NixOS, but I personally don't do so,
so I will not detail the process here.

### Device configuration

To use UnifiedPush on your Android device you need to have both the
[Nextcloud](https://f-droid.org/en/packages/com.nextcloud.client/) and the
[NextPush](https://f-droid.org/en/packages/org.unifiedpush.distributor.nextpush/)
app installed. Opening the NextPush app should guide you through setting it
up. Once you've done that, you can start registering apps with NextPush. For
example, to register Element Android go to the Notifications settings in Element
Android and pick NextPush as your notification method. To set up Tusky, I
haven't found a better way than logging out and back in again.

Once you've followed these steps, you should have a working push notification
setup.

## Conclusion

As you can see, the process for setting up UnifiedPush using Nextcloud is not
that involved. I was personally really impressed with how quickly I was able to
get everything working. It is really nice to see that the open-source and free
software community can implement the niceties that we've come to expect from
modern life without needing a big tech giant to do so.
