#
# MIT License
#
# Copyright (c) 2022 LiGuo <bingyang136@163.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#

nohup java -server -Xms4048M -Xmx4048M -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -Xloggc:/var/logs/doorgod.service.panli.com/gc.log -XX:HeapDumpPath=/var/logs/doorgod.service.panli.com/heapdump.hprof-XX:+CMSParallelRemarkEnabled -XX:+PrintGCDateStamps -XX:+ScavengeBeforeFullGC -XX:+CMSScavengeBeforeRemark -verbose:gc -XX:+PrintGCDetails -XX:+HeapDumpOnOutOfMemoryError -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=50M -XX:+UseCMSCompactAtFullCollection -XX:CMSInitiatingOccupancyFraction=70 -Dspring.profiles.active=dev -jar /Users/edz/framework-java/door-god/door-god-api/target/door-god-api-1.0-SNAPSHOT.jar &
