# Song Queue Manager

## Overview

A Ruby on Rails application designed to make it easier for Rock Band and Karaoke attendees to manage
the queue - which bands go up, when they do, and how many songs they play. It is intended to
eliminate the days the queue was done by paper slips or by memory - eliminating human error,
making it fairer for attendees, and making it easier for management.

## Running the Software

In order to run the software locally, clone the repository, and then create and migrate the
database as follows.

    bundle exec rake db:create
    bundle exec rake db:migrate

You can then start the app using the following.

    bundle install
    bundle exec rails server

## Test Suite

Song Queue Manager uses the minitest as the test framework. In order to run the test suite, you can
run the following command.

    bundle exec rake test

Song Queue Manager contains Controller, Helper, Integration, and Mailer tests, and a set of fixtures
for each model.

## LICENSE

Song Queue Manager is released under the three-clause BSD license.
