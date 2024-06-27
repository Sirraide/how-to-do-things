# Prerequisites

The official tutorial can be found here: https://www.mediawiki.org/wiki/Manual:Installing_MediaWiki

To set up a wiki, simply work through all of the sections here in order; a
basic understanding of SQL, databases, and nginx configurations is assumed.

This is only about setting up a wiki for *trusted users only*, i.e. only an
admin can create user accounts, and no-one else can. If you want to deal with
random people on the internet being able to create accounts and edit your wiki,
then go ahead, but don’t expect any help from me when it comes to dealing with
the consequences...

## Database
Use either mysql or mariadb (other databases might work but aren’t tested against
all plugins etc, so just use either of those). You need to create a database for
the wiki and a user like so (this assumes the database is running on the same
system as the wiki instance). I recommend you open a new terminal for this and
leave it open and connected to the db after you’re done, because we’ll have to run
all of these *again* later on.
```sql
-- Create the database for the wiki.
CREATE DATABASE foo_wiki;

-- Create a user that can edit it.
CREATE USER 'foouser'@'localhost' IDENTIFIED BY 'super secure database password';

-- Grant the user edit rights on the new database.
GRANT ALL PRIVILEGES ON foo_wiki.* TO 'foouser'@'localhost' WITH GRANT OPTION;

-- Dew it.
FLUSH PRIVILEGES;
```

## Directory structure
THIS PART IS IMPORTANT, READ IT CAREFULLY!

Next, download a mediawiki release from the link above and un-`tar` it. The resulting
directory should contain a bunch of subdirectories and other things. It should look
something like this:
```bash
# Do this in the root directory.
$ cd /

# Unpack the tarball.
$ sudo tar zxvf mediawiki-1.41.tar.gz
mediawiki-14.1/...

# View its contents to make sure we did this right.
$ ls mediawiki-1.14
cache        mw-config     CODE_OF_CONDUCT.md          HISTORY              README.md
docs         resources     composer.json               img_auth.php         RELEASE-NOTES-1.41
extensions   skins         composer.local.json-sample  index.php            rest.php
images       tests         COPYING                     INSTALL              SECURITY
includes     vendor        CREDITS                     jsduck.json          thumb_handler.php
languages    api.php       docker-compose.yml          load.php             thumb.php
maintenance  autoload.php  FAQ                         opensearch_desc.php  UPGRADE
```

Now, the nginx configuration for this expects a directory structure of the form
`/some-root-dir/w/<contents of this directory>`; if you get this wrong, nothing
will work, so rename it accordingly:
```bash
$ cd /
$ sudo mkdir /foowiki
$ sudo mv mediawiki-1.14 w
$ sudo mv w foowiki/
```

Now, check the directory structure one more time.
```bash
$ cd /
$ ls /foowiki/w/
cache        mw-config     CODE_OF_CONDUCT.md          HISTORY              README.md
docs         resources     composer.json               img_auth.php         RELEASE-NOTES-1.41
extensions   skins         composer.local.json-sample  index.php            rest.php
images       tests         COPYING                     INSTALL              SECURITY
includes     vendor        CREDITS                     jsduck.json          thumb_handler.php
languages    api.php       docker-compose.yml          load.php             thumb.php
maintenance  autoload.php  FAQ                         opensearch_desc.php  UPGRADE
```

Finally, make sure that Nginx can access this directory; this can be done by
transferring ownership to the user running Nginx. Unfortunately, the name of
this user is platform dependent: on Fedora, it’s `nginx`, but on Debian, for
some ungodly reason, it’s `www-data`:
```bash
$ sudo chown nginx:nginx -R /foowiki
```

## Nginx configuration
There are *two* nginx configs that we will be dealing with here: one for setting
the wiki up locally, and one when we move the wiki to the server that we want it
to run on. Locally, something like this will do (adapted from https://www.mediawiki.org/wiki/Manual:Short_URL/Nginx):
```nginx
server {
    listen [::]:80 default_server;
    listen 80 default_server;

    server_name _;
    root /foowiki; # NOT /foowiki/w !!!
    index index.php;

    # Required for large uploads.
    client_max_body_size 20M;

    # Location for wiki's entry points
    location ~ ^/w/(index|load|api|thumb|opensearch_desc|rest|img_auth)\.php$ {
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param REDIRECT_STATUS 200;
        fastcgi_pass unix:/run/php-fpm/www.sock;
    }

    # Images
    location /w/images {
        # Separate location for images/ so .php execution won't apply
    }
    location /w/images/deleted {
        # Deny access to deleted images folder
        deny all;
    }
    # MediaWiki assets (usually images)
    location ~ ^/w/resources/(assets|lib|src) {
        try_files $uri =404;
        add_header Cache-Control "public";
        expires 7d;
    }
    # Assets, scripts and styles from skins and extensions
    location ~ ^/w/(skins|extensions)/.+\.(css|js|gif|jpg|jpeg|png|svg|wasm|ttf|woff|woff2)$ {
        try_files $uri =404;
        add_header Cache-Control "public";
        expires 7d;
    }
    # Favicon
    location = /favicon.ico {
        try_files /w/favicon.ico =404;
        add_header Cache-Control "public";
        expires 7d;
    }

    # License and credits files
    location ~ ^/w/(COPYING|CREDITS)$ {
        default_type text/plain;
    }

    ## Uncomment the following code if you wish to use the installer/updater
    ## installer/updater
    location /w/mw-config/ {
        # Do this inside of a location so it can be negated
        location ~ \.php$ {
            include /etc/nginx/fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_pass unix:/run/php-fpm/www.sock;
        }
    }

    # Handling for Mediawiki REST API, see [[mw:API:REST_API]]
    location /w/rest.php/ {
        try_files $uri $uri/ /w/rest.php?$query_string;
    }

    ## Uncomment the following code for handling image authentication
    ## Also add "deny all;" in the location for /w/images above
    #location /w/img_auth.php/ {
    #	try_files $uri $uri/ /w/img_auth.php?$query_string;
    #}

    # Handling for the article path (pretty URLs)
    location /wiki/ {
        rewrite ^/wiki/(?<pagename>.*)$ /w/index.php;
    }

    # Allow robots.txt in case you have one
    location = /robots.txt {
    }
    # Explicit access to the root website, redirect to main page (adapt as needed)
    location = / {
        return 301 /wiki/Main_Page;
    }

    # Every other entry point will be disallowed.
    # Add specific rules for other entry points/images as needed above this
    location / {
        return 404;
    }
}
```
The reader is assumed to know what to do with a `server { ... }` block. Furthermore,
this does not cover setting up HTTPS or anything like that seeing as that is entirely
orthogonal to setting up a wiki. Set up HTTPS for this `server` block (or rather, the
one we’ll be using when we move this to the server) as you usually would, and everything
else will work just fine (with a caveat, but we’ll get back to that later).

Most of the `location` blocks are just redirecting URLs around a bunch, but there
are two things worth pointing out here:

1. The `root` of this server is set to `root /foowiki`. This is the directory
   that contains the `w` directory, *which in turn contains* the actual contents
   of the wiki. If you put your wiki somewhere else, you will have to adjust this.

2. There are *two* instances of `fastcgi_pass` in total. Both of these point to
   a unix socket that nginx will use to communicate with the PHP backend. You need
   to set this path to `unix:/path/to/socket` where `/path/to/socket` is the path
   of the `php-fpm` socket on your system. This is platform-specific. On Fedora 40,
   for instance, it is `/run/php-fpm/www.sock`, so you would have to set this to
   `unix:/run/php-fpm/www.sock`.

   To figure out what this path is, recursively grep for `listen =` in any directories
   in `/etc` that start with `php` (or just in all of `/etc`, but the output will be
   a lot noisier...); for example
   ```bash
   $ grep -rn 'listen =' /etc/php*
   /etc/php-fpm.d/www.conf:38:listen = /run/php-fpm/www.sock
   ```
   The path to the right of the `=` will be the path of the socket; you can confirm
   this using `stat`:
   ```bash
   $ stat /run/php-fpm/www.sock
     File: /run/php-fpm/www.sock
     Size: 0         	Blocks: 0          IO Block: 4096   socket
   ```

Next, start or reload nginx. Also make sure you’re not also running apache at the
same time since that will prevent nginx from binding to port 80:
```bash
$ sudo nginx -t         # Test that the config file(s) are well-formed.
$ sudo nginx -s reload  # Reload the config.
```

Now, nginx should be up and running. You may also have to install `php-fpm` and start
its service because, again, that’s our backend.

## SELINUX
If you’re in the unfortunate situation of using a distro that uses SE Linux, you’ll
have to bash it over the head with a sledgehammer to tell it that the PHP wiki code
is not malware:

```bash
$ sudo semanage fcontext -a -t httpd_sys_rw_content_t '/foowiki(/.*)?'
$ sudo restorecon -v '/foowiki' -R
```

If this doesn’t work for you, then my bad. I have no idea what this does in the first
place, but it makes SE linux shut up.

# ‘Installing’ the Wiki
The next section of the official tutorial is this: https://www.mediawiki.org/wiki/Manual:Config_script

At this point, navigate to `http://localhost/w/mw-config/index.php?` and follow the
installer; most things are self-evident, but there are some notes about some of the
pages below. Each heading corresponds to page in the installer (it may not be the
page title, but it’s obvious what page this is about)

## Environmental checks page
Make sure you’ve installed EVERYTHING that it tells you to install! If you don’t know
how, google it. If something is missing, install it, reload the page, until nothing is
missing anymore and it says, in green ‘The environment has been checked. You can install
MediaWiki.’ You can ignore this warning:
```
Warning: Because of a connection error, it was not possibly to verify that images in your
uploads directory, respond with the HTTP header X-Content-Type-Options: nosniff to protect
browsers from potentially unsafe files.

It is highly recommended to configure appropriate response headers on your webserver before enabling uploads.
```

## Connect to database
Database type: Pick `MariaDB, MySQL, or compatible`

Database host: `localhost`

Database name (no hyphens): `foo_wiki` (the name we picked in the DB section)

Database table prefix (no hyphens): Leave this empty

Database username: `foouser` (the name we picked in the DB section)

Database password: `super secure database password` (the password we picked in the DB section)

## Database settings
Use the same account as for installation: Tick this

## Name
When you’re done with this page, make sure to scroll all the way down
and select ‘Ask me more questions’.

## Options
User rights profile: I’m using `Authorised editors only`, i.e. everyone can view the wiki, but
an admin has to create an account for someone if they want to edit pages. You can also change
this later.

If you know how to set up a mail server, by all means go ahead and enable emails, but I don’t,
so I tend to disable them entirely (if you haven’t configured mail properly, it won’t work anyway).

In the `Skins` section, *make sure to select a default skin*! ‘Vector’ is the one Wikipedia uses
by default if you want to go for that. You can of course change this later as well.

In the Extensions section, look into what they do and enable them as needed. All of the ones on this
page are bundled with your installation, so you can always enable them later without having to install
anything. Some of the useful ones include (listed in top-down order as they appear on the page):

- `Echo `for notifications; other extensions require this.
- `WikiEditor` and `CodeEditor` (`VisualEditor` tends to confuse people in my experience) so you can edit pages.
- `CategoryTree` for a tree view of your wiki.
- Just enable everything in `Parser hooks`, in particular:
    - `Cite` for footnotes.
    - `ImageMap` for images that can contain links.
    - `Math` if you’re into formatting equations.
    - `ParserFunctions` for improved templates.
    - `Scribunto` if you like Lua (and some templates from other wikis may require this in my experience).
    - `SyntaxHighlight_GeSHi` for syntax highlighting of source code.

And a few more in here, but I got bored listing all of them... Make sure you *don’t* enable e.g. `AbuseFilter`
if you’re making a private wiki, because it’s just going to annoy people, and you have total control as to who
gets to do what anyway.

For ‘Directory for deleted files’, `$wgResourceBasePath/images/deleted` corresponds to what the nginx config
above expects. Also, enable file uploads above that (more on this later).

At the bottom of the page, in ‘Settings for object caching’, select `PHP object caching`.

## Install
Press ‘Continue’. This should finish instantly; everything should just say ‘done’. Press ‘Continue’ again.

## Complete!
Your browser will prompt you to download a file called `LocalSettings.php`. This is the main configuration
file for the wiki, and any configuration such as adding more extensions is done by editing this file (unless
it’s a global PHP setting that you need to change in your `php.ini`).

Put this file in the `w` directory of your wiki, next to all the other files:
```bash
$ sudo mv ~/Downloads/LocalSettings.php /foowiki/w/
```

After that, click on the link that says ‘enter your wiki.’ This completes the installation process, and we
now move on to post-install configuration.

# Post-‘Install’ Configuration
Clicking the aforementioned link should redirect you to http://localhost/w/index.php?title=Main_Page (we’ll
fix the ugly links later after moving the wiki to the server, don’t worry). The login button (at least if 
you’re using the default theme) is in the top-right corner of the screen, log in as you would on any other 
wiki and create users etc.

(I’m candidly too lazy to write documentation for this part because it’s mostly self-evident; just go to the
`Special Pages` page and browse a bit; pages of interest may be `All pages`, `Create account`, `User rights`,
`Export pages`, and `Import pages`.)

# Moving the Wiki to the Server
Stop Nginx and php-fpm to make sure nothing weird happens. Next, we need to move three things to the server:
1. the wiki itself;
2. the database;
3. the nginx config.

Each of these may have to be adjusted slightly, so lets go over them in turn.

## Moving the wiki
This one is fairly simple: just `tar` the entire directory and copy it to the server; unpack it there. I like
putting all of my server-related stuff in `/srv/`, so I’ll be putting it in `/srv/foowiki` (once again, that
means that e.g. out `LocalSettings.php` is at `/srv/foowiki/w/LocalSettings.php`). Now, in my case this is a
Debian server, so we need to make sure the right user owns this directory:
```bash
$ sudo chown www-data:www-data -R /srv/foowiki
```

That completes moving the wiki.

## Moving the database
Next up: the database. For this, we need to export the database on our system, copy the file, and import it
on the server. First, dump the entire database. We use `mysqldump` for that (irrespective of whether we’re using
mariadb or mysql!). You’ll probably have to do this as the root user. I have it set up to where I `sudo mariadb`
to log into the db, but if you’ve set a password for the mariadb `root` user, you may have to do `-u root -p` or
however that works again. In my case, I dump the DB using:
```bash
# Recall that we called our database 'foo_wiki'.
$ sudo mysqldump foo_wiki > foo_wiki.sql
```

Copy this file to the server, and perform the same initialisation steps as above:
```sql
-- Create the database for the wiki.
CREATE DATABASE foo_wiki;

-- Create a user that can edit it.
CREATE USER 'foouser'@'localhost' IDENTIFIED BY 'super secure database password';

-- Grant the user edit rights on the new database.
GRANT ALL PRIVILEGES ON foo_wiki.* TO 'foouser'@'localhost' WITH GRANT OPTION;

-- Dew it.
FLUSH PRIVILEGES;
```

Then, load the database dump:
```bash
# ‘mysql’ instead of ‘mariadb’ if that’s what you’re using.
$ sudo mariadb foo_wiki < foo_wiki.sql
```

This completes setting up the database. If you want to, log back into the db and
check that we’ve actually imported stuff:
```sql
USE foo_wiki;
SHOW TABLES;
```

## Setting up nginx
Finally, we need to make some changes to the nginx configuration. Start by copy-pasting
the configuration that we used above. Then,

- Change the `server_name` from `_` to the domain you want to use, e.g.
  `foowiki.example.com`.

- Change the `root` to reflect where we put the wiki. Recall that we put it in `/srv/`
  instead of the root directory, so we need to change this to `/srv/foowiki` (*without*
  the `w`!!!).

- Comment out or delete the location block that starts with `location /w/mw-config/`;
  this is what we used to ‘install’ the wiki; people should not have access to that once
  it is operational, so we remove this block (this way, it will fall through to a
  generic ‘404’ rule at the bottom of the `server` block).

- Change the `fastcgi_pass` socket to wherever the socket actually is on the server (see
  the section above where we first set this up).

And that’s pretty much it. You might have to make some more changes depending on your
server configuration, e.g. set up HHTPS, add a redirect from port 80 to 443, etc. but you
can figure out that part yourself. This is not an Nginx tutorial, after all.


## Final Configuration Steps
Open `LocalSettings.php` on the server. BE CAREFUL WHEN YOU EDIT THIS FILE and make sure
you use something like `sudo -e` or change the permissions back to where the Nginx user
can view this file. Furthermore, any typos in here will take down your entire site! Make
sure to check for e.g. missing semicolons and so on if that happens. The file has to be
valid PHP! (Note however that the closing PHP tag at the end of the file is usually omitted.)

- Change the `$wgServer` variable to point to `https://foowiki.example.com` (or `http://` if
  you don’t want to use HTTPS).

- You probably want to enable short links (e.g. `/wiki/foobar` instead of the more ugly
  `/w/index.php?title=foobar`); our nginx configuration is already set up to do that, but
  we still need to enable them here. To do that, add the following anywhere (I like to put
  it below the `$wgScriptPath`:
  ```php
  ## Enable short urls.
  $wgArticlePath = "/wiki/$1";
  $wgUsePathInfo = true;
  ```

- You probably want a custom logo for your wiki. Put two files in `w/resources/assets/`,
  a 100×100 and a 135×135 one, and then change the keys in the `$wgLogos` map to point to
  those files instead. For more sophisticated logos, see https://www.mediawiki.org/wiki/Manual:$wgLogos.
  As an aside, pretty much every variable in `LocalSettings.php` is documented in similar fashion.

- Set allowed file extensions for file uploads. You probably want to allow uploading images,
  videos, and fonts. This can be done by extending the `$wgFileExtensions` variable; you can
  either edit it directly, or extend it later on like so:
  ```php
  $wgFileExtensions = array_merge(
      $wgFileExtensions, [
          'pdf', 'ttf', 'otf', 'woff', 'woff2', 'jxl',
          'ogg', 'mp3', 'wav', 'svg'
      ]
  );
  ```

Lastly, you might eventually want to increase the maximum upload size if you want people to
be able to upload larger images etc. This, unfortunately, is not entirely straight-forward,
as we need to change this setting in 4–5 different places.

- In `LocalSettings.php`:

    1. Adjust `$wgMaxUploadSize` to the maximum upload size *in bytes*,
       e.g. `15728640` for 15MB.

    2. If you want people to be able to view thumbnails for large images, also set the `$wgMaxImageArea`
       variable in `LocalSettings.php` to a reasonably large value. This value is in *pixels*, so e.g.
       a value of `10e7` corresponds to 10MP, or a 10,000×10,000 image.

- Open your `php.ini` (which you can find by e.g. using `locate`; it should be *somewhere* in
  `/etc/php` or `/etc/php-fpm` or something similar). If there’s more than one, use the one with
  `fpm` in its path.

  IMPORTANT: These settings are GLOBAL, meaning they affect *everything* that uses `php-fpm` on your
  system! If you want to limit the maximum upload file size for your wiki only, do that in `LocalSettings.php`
  instead instead of reducing the value in here.

  With that out of the way, the value in here still needs to be greater than or equal to the one in
  `LocalSettings.php`, otherwise you’ll get a rather confusing error when you try to upload something.
  Specifically, we need to:

    3. Adjust the value of `post_max_size` (NO `$` here!!! Search for where that setting is in the file!)
       to e.g. `15M` (or a larger value), matching what we specified in `LocalSettings.php`.


    4. Make sure `file_uploads` is set to `On` (`file_uploads = On`).

    5. Set `upload_max_filesize` to a value matching `post_max_size`. In practice, for the purposes
       of setting up a wiki alone, it doesn’t matter what these two values are set to so longer as
       they are both each greater than what we specified in `LocalSettings.php`, because the smallest
       of these three will ultimately be the limit of what you can upload.

- Finally, we need to tell nginx to allow a request body that is at least that large:

    6. Note that we’ve already done that in the configuration above (that’s what the `client_max_body_size`
       setting is for). This setting is per `server` block.

In the future, if you want to decrease the upload file size limit, just change it in `LocalSettings.php`; if
you want to *increase* it, you may have to edit multiple or even all of the places above.

# Final steps
Lastly, remember to also do the SE Linux thing if your server uses SE Linux, because you’ve probably already
forgotten about that at this point...

This completes setting up the wiki. Make sure to reload the nginx configuration as we did locally, and your
wiki should be up and running! As mentioned above, any further configuration will usually happen either via
a web interface, or by editing `LocalSettings.php`. Fortunately, pretty much all the variables in there (and
all the ones you can put in there) are rather well documented. You can typically just search for whatever you
want to know on Google and you’ll find the relevant documentation pretty quickly.
