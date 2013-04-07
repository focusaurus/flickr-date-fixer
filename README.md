# flickr date fixer

## The Problem

My smartphone sets the wrong date on all my photos. Specifically, I have a Android "Froyo" based LG Optimus V smartphone. It has a bug such that every photo I take with the flickr Android app and upload to flickr gets the "taken" date set to December 8, 2002. Google won't fix this bug. I don't know why. It's frustrating. So frustrating that I wrote a web app to go and fix it.

## The Solution

This web app will go through your flickr photos, find ones with the "taken" date within the specified range, and set their "taken" date to match their "uploaded" date.