## Quake Load Tests
This gem is designed to perform stress tests on your REST API.

#### Clone the gem

```bash
git clone https://github.com/michaelalves204/quake_load_test
```
#### Navigate to the quake_load_test directory and install the gem

```bash
cd quake_load_test
gem build quake.gemspec
gem install quake-1.0.0.gem
bundle install
```

#### Irb for use gem

```bash
irb(main):001> require_relative 'lib/quake'
=> true
irb(main):002> Quake.new(10, "http://localhost:3000/users", "get").call
```

##### After installing the gem

```bash
rake --tasks
```

##### The rake command will be prompted

`rake execute_quake[requests,url,type,data,headers]`

| requests | url | type | data | headers|
|------------|------------|------------|------------|------------|
| Number of requests | URL to make requests | GET/POST/PATCH/PUT/DELETE | Request body parameters | Request headers |

### Example


#### GET

```bash
rake execute_quake[10000,"http://localhost:3000/",get]
```

```bash
rake execute_quake[10000,"http://localhost:3000/posts",get,nil,"{'authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJtaWNoYWVsQGdt'}"]
```
#### POST

```bash
rake execute_quake[10000,"http://localhost:3000/login",post,"email=example@email.com&password=password"]
```
