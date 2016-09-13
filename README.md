# PHP7 (FPM) + Nginx (Alpine Linux)
Build our PHP7 + Nginx container (It was created for testing and developing our apps)

### How to use this image
It must map the application folder to make it work
```
$ docker run --name php7_testing -v /my/own/app:/www -d gfg/docker-php7alpine
```

### PHP7 [Modules]
amqp, bcmath, Core, ctype, date, dom, fileinfo, filter, hash, json, libxml, mbstring, mcrypt, mongodb, openssl, pcre, Phar, redis, Reflection, session, SimpleXML, SPL, standard, tokenizer, xdebug, xml, xmlwriter, Zend OPcache, Xdebug
