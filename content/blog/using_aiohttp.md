+++
Tags = ["Development","python"]
Description = ""
date = "2017-02-25T14:18:57-06:00"
title = "Asynchronous HTTP Requests in Python"
Categories = ["Development","python"]
draft = false
author = "Eli Uriegas"
authorlink = "http://github.com/seemethere"
aliases = [
    "post/asynchronous-http-requests-in-python"
]

+++

# Overview

Asynchronous programming is a new concept for most Python developers (or maybe it's just me)
so utilizing the new asynchronous libraries that are coming out can be difficult at least
from a conceptual point of view.

The library I'll be highlighting today is [aiohttp](https://github.com/KeepSafe/aiohttp).
If you're familiar with the popular Python library `requests` you can consider `aiohttp` as 
the asynchronous version of `requests`.

Usage is very similar to `requests` but the potential performance benefits are, 
in some cases, absolutely insane.

I'll be taking you through an example using the NBA's statistics API (a notoriously slow API) 
to show you the performance benefits of asynchronous HTTP requests.

# Example Explanation

So for our example we will be sending requests to the NBA's statistics API to gather 
information concerning common player statistics like points per game, rebounds per game, etc. 
We would also like to store this data in local `json` files as to do repeated analysis on them 
without having to re-hit the API.

If you haven't used the NBA's statistics API you should know that it can be extremely slow.
Calls can take upwards of 5-6 seconds and collecting data from the API can be major pain.

# The Non-Asynchronous Way

```python
import requests

base_url = 'http://stats.nba.com/stats'
HEADERS = {
    'user-agent': ('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) '
                   'AppleWebKit/537.36 (KHTML, like Gecko) '
                   'Chrome/45.0.2454.101 Safari/537.36'),
}


def get_players(player_args):
    endpoint = '/commonallplayers'
    params = {'leagueid': '00', 'season': '2016-17', 'isonlycurrentseason': '1'}
    url = f'{base_url}{endpoint}'
    print('Getting all players...')
    resp = requests.get(url, headers=HEADERS, params=params)
    data = resp.json()
    player_args.extend(
        [(item[0], item[2]) for item in data['resultSets'][0]['rowSet']])


def get_player(player_id, player_name):
    endpoint = '/commonplayerinfo'
    params = {'playerid': player_id}
    url = f'{base_url}{endpoint}'
    print(f'Getting player {player_name}')
    resp = requests.get(url, headers=HEADERS, params=params)
    print(resp)
    data = resp.text
    with open(f'{player_name.replace(" ", "_")}.json', 'w') as file:
        file.write(data)


player_args = []
get_players(player_args)
for args in player_args:
    get_player(*args)
```

## So what does it do?
The function `get_players` calls out to the API to gather all of the player ID's along 
with their names and edits a list in-place to put them in there (I know a terrible 
but I wanted to keep it close to the async example).

After gathering the player ID's and player names the program synchronously gathers player 
information and stores it in files with the format `FIRSTNAME_LASTNAME.json`.

It's a fairly straightforward program and takes around *12 minutes* of total time.

# The Asynchronous Way
```python
import asyncio
import aiofiles
import aiohttp

base_url = 'http://stats.nba.com/stats'
HEADERS = {
    'user-agent': ('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) '
                   'AppleWebKit/537.36 (KHTML, like Gecko) '
                   'Chrome/45.0.2454.101 Safari/537.36'),
}

async def get_players(player_args):
    endpoint = '/commonallplayers'
    params = {'leagueid': '00', 'season': '2016-17', 'isonlycurrentseason': '1'}
    url = f'{base_url}{endpoint}'
    print('Getting all players...')
    async with aiohttp.ClientSession() as session:
        async with session.get(url, headers=HEADERS, params=params) as resp:
            data = await resp.json()
    player_args.extend(
        [(item[0], item[2]) for item in data['resultSets'][0]['rowSet']])

async def get_player(player_id, player_name):
    endpoint = '/commonplayerinfo'
    params = {'playerid': player_id}
    url = f'{base_url}{endpoint}'
    print(f'Getting player {player_name}')
    async with aiohttp.ClientSession() as session:
        async with session.get(url, headers=HEADERS, params=params) as resp:
            print(resp)
            data = await resp.text()
    async with aiofiles.open(
            f'{player_name.replace(" ", "_")}.json', 'w') as file:
        await file.write(data)

loop = asyncio.get_event_loop()
player_args = []
loop.run_until_complete(get_players(player_args))
loop.run_until_complete(
    asyncio.gather(
        *(get_player(*args) for args in player_args)
    )
)
```

## So what does it do?
So this, like the synchronous, version follows pretty much the same steps and provides the
same output but execution time is about *22 seconds*, which in my opinion is a ridiculous 
performance boost.

# Conclusion
So 22 seconds versus 12 minutes is a very **huge** difference in performance and it should 
be noted that the outcomes of the 2 programs are exactly the same.

So while asynchronous programming may seem new and mysterious to a lot of developers out there.
The performance benefits are very real and tangible right now.
