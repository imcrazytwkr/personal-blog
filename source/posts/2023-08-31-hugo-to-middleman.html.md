---
title: How to stop worrying and port a Hugo template to Middleman
date: 2023-08-31
tags: ruby, js, middleman, vite
---

Today I pretty much had to setup a website, mostly to serve as an index for all of my contacts and profile links. Just plopping up a single page with social media and GIT profiles seemed pretty barren for a modern world though and since most of the other devs I know blog from time to time, the idea of what to make ended up being a no-brainer: just make an ol' reliable blog.

When browsing through templates I stumbled upon [Paper](https://github.com/nanxiaobei/hugo-paper) which looks pretty neat but it has some design-related and HTML meta-related bugs. Aforementioned problems seemed fixable but since it was made for Hugo and I wasn't particularly fond of it, I decided to go an extra mile and port the template to Middleman, fixing all the issues along the way.

## Why not just use Hugo?

First, let us get some things over with: I like Go as a programming language. It is amazing and I enjoy building [things](https://github.com/imcrazytwkr/feedhub)  in it. Sadly, I can't really say the same about Hugo. It's a decent tool alright but I find it a bit too inflexible in terms of code structure. That works well for "templates" with more-or-less standardized underlying data like you'd want for blog posts. Does it necessary work well when you have more one-off pages than "templates"? - not for me.

## Why middleman then?

That's a good question to ask. I like both ruby and middleman. Additionally, I've been [building](https://git.twkr.dev/convention-machine/awcon.ru) [sites](https://git.twkr.dev/convention-machine/scpfest.net) [with it](https://git.twkr.dev/convention-machine/rubronycon.ru) [since 2017](https://git.twkr.dev/convention-machine/derpfest.online) and it worked for me fairly well all this time. Middleman is also fairly flexible and most, if not all, of its [helpers](https://middlemanapp.com/basics/helper-methods/) are built on top of their respective [Padrino versions](http://padrinorb.com/guides/application-helpers/overview/). This is important because that means that [Vite](https://vitejs.dev) can be natively integrated into them using [Padrino integration](https://vite-ruby.netlify.app/guide/padrino.html) from Vite Ruby project.

Technically speaking, it isn't necessary to pick specifically Vite. [Webpack](https://webpack.js.org/) or any other JS bundler paired with a decent enough asset processor could have been used instead. However Vite has an advantage of being easily configurable and having an existing library that helps a lot with integrating it into middleman.

## Setting up Vite resource pipeline

This section can be alternatively titled as "Middleman + Vite: [the Good, the Bad and the Ugly](https://en.wikipedia.org/wiki/The_Good,_the_Bad_and_the_Ugly)" because integrating those two in practice has ended up being quite a rollercoaster. To honor the alternative title of this section, let me first explain the good things:

**[Vite-Ruby](https://vite-ruby.netlify.app/) and [Vite-Padrino](https://github.com/ElMassimo/vite_ruby/tree/main/vite_padrino)** have provided a working integration between Middleman and Vite. Initial setup was as easy as adding said gems to Gemfile and importing Padrino helpers into middleman.

**Middleman [external pipeline](https://middlemanapp.com/advanced/external-pipeline/)** lets you easily and efficiently launch Vite dev server or build action depending on the environment. Assuming you correctly pass `RACK_ENV` to middleman, it only takes 8 lines of meaningful (excluding blank lines and import directives) code to get going:

```ruby
activate :external_pipeline,
  name: :vite,
  command: "bin/vite #{build? ? :build : :dev}",
  source: ViteRuby.config.public_dir,
  latency: 1

configure :development do
  use ViteRuby::DevServerProxy, ssl_verify_none: true
end
```

Now, for the "bad and ugly" part: it turns out that while helpers in Middleman piggyback off of Padrino ones under the hood, they are not always API-compatible which may lead to Middleman crashing with weird non-descriptive errors when you use Vite-Padrino helpers as-is.

**Incompatible `asset_path` helper API** breaks everything when you try to import any kind of Vite-processed asset that is not a JS or TS entry-point. Luckily, it is fixable and there are two ways you can do that: [monkey-patch `asset_path` helper](https://github.com/knoxjeffrey/personal_website/blob/9fb317f7153db5520b790e661feb67d5ab4aae41/helpers/asset_tag_helpers.rb#L30) to conform to Padrino specifications or rewrite Vite-Padrino helpers to conform to middleman API. Latter seems like a more reasonable approach to me because patching API that is frequently used inside Middleman itself can lead to unpredictable consequences down the road.

## Porting the template

Generally speaking, porting template has been pretty straightforward. Most places just required changing templating expressions from Go [html/template](https://pkg.go.dev/html/template)  to [ERB](https://docs.ruby-lang.org/en/3.2/ERB.html) syntax and some subjectively [hacky if-conditions](https://github.com/nanxiaobei/hugo-paper/blob/3d9563e3cfa64372fa1e87bba97494251bf0eb52/layouts/_default/list.html#L4) to be rewritten as separate layouts. However, there were also some nasty surprises down the road.

Everything related to **social links icon strip was hardcoded**. It does not seem like it when you first look at the template because it iterates over config and maps icons but in reality all icons are exactly square and spacing is done in margins. This makes it extremely messy to add another icon that does not have a perfectly square viewbox like the [Gitea logo](https://forkaweso.me/Fork-Awesome/icon/gitea/).

Another problem is that this component has also relied on **hacking icons in using [CSS variables and background-url helper](https://github.com/nanxiaobei/hugo-paper/blob/3d9563e3cfa64372fa1e87bba97494251bf0eb52/layouts/partials/header.html#L88)** from tailwind that only works if you keep icons outside your asset pipeline. Otherwise icon filenames will have hashes automatically appended to them in production. Tailwind, however, does not know about it during CSS generation which would lead to icons being displayed only in development environment and not in production.

The original template also uses **fixed 3-column [footer layout](https://github.com/nanxiaobei/hugo-paper/blob/3d9563e3cfa64372fa1e87bba97494251bf0eb52/layouts/partials/footer.html)** which breaks on mobile unless your site's name is very short ("example website" is already too long).

Last but not least, **RSS/Atom feed was outright missing.** Now, this one may not be a bug of a template but a feature of Hugo that I couldn't find documentation for anywhere. Luckily, Middleman's blog template provides reasonable enough Atom feed [implementation example](https://github.com/middleman/middleman-templates-blog/blob/master/template/source/feed.xml.builder) and it only required some minor adjustments so I didn't have to write one completely from scratch.

## Removed features

Sometimes less is more. In case of this blog, there were two features from the original Paper template that I have omitted due to them being both overly complicated to implement correctly and subjectively redundant.

**Icon themes for dark mode button** seemed like a fun feature to have but with properly integrated asset pipeline it became one hell of a job to implement it. When your icons are automatically hashed using Vite during build process that builds an instance of Tailwind in parallel, properly setting up background images with moderately complicated CSS transition becomes extremely tedious. Considering that "Paper" is a minimal and otherwise monochrome theme, colorful icon looks out of place. Flat monochrome one fits the theme much better if you ask me.

**Comments** may be useful but tend to be a pain to moderate and a privacy nightmare. [Some](https://jcs.org) [people](https://jvns.ca/) whose blogs I follow tend to keep them disabled because of these very reasons and instead rely on more direct audience interaction methods like Mastodon or trusty old email. On the other hand, there are proponents of having comments enabled on your blog so there is a change I will add it back once I figure out a way to integrate them in a less invasive way.

## More resources

During my research into integration of Vite with Middleman, I stumbles upon these two posts by Jeff Knox:

- [Dropping Webpack for Vite Part 1](https://www.jeffreyknox.dev/blog/dropping-webpack-for-vite-part-1/)
- [Dropping Webpack for Vite Part 2](https://www.jeffreyknox.dev/blog/dropping-webpack-for-vite-part-2/)

They were a great help during my escapade. The second post was outright invaluable when I've stumbled upon a weird error when importing stylesheets. So shout out to Jeff for pioneering Vite + Middleman integration and thank you for sticking with this post all the way to the end!
