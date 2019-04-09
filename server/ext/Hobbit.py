#!/usr/bin/env python
# A module for Hobbit
#

def trends(hostname):
    return Hobbit(hostname, type='data', test='trends') # dont_moan=1

class Hobbit:
    """ A hobbit class """

    def __init__(self, hostname=None, type='status', test='uninitialized'):
        import socket
        import subprocess
        import string
        import signal
        signal.signal(signal.SIGINT,self.moan)

        self.colorarr={"clear":0,
                       "green":1,
                       "purple":2,
                       "yellow":3,
                       "red":4}
        if hostname is None:
            self.hostname=socket.getfqdn()
        else:
            self.hostname=hostname
        self.hostname=string.replace(self.hostname, '.', ',')
        #self.text=''
        self.hostclass=test
        self.textarr=[]
        self.test=test
        self.color='clear'
        self.type=type

    # Return the "highest" colour
    def max_color(self,a,b):
        if not a in self.colorarr:
            sys.exit('Unknown color '+a)
        if not b in self.colorarr:
            sys.exit('Unknown color '+b)
        return (a, b)[self.colorarr[b]>self.colorarr[a]]

    # Add a colour
    def add_color(self,color):
        self.color=self.max_color(self.color, color)

    # Return the "highest" colour
    def lineprint(self,line):
        #self.text+=line+'\n'
        self.textarr.append(line)

    # Add a line with colour
    def color_print(self,color,line):
        self.add_color(color)
        self.lineprint(line)

    # Add a line prefixed with colour
    def color_line(self,color,line):
        self.color_print(color,'&'+color+' '+line)

    # Send the message
    def send(self):
        import time
        import os
        import subprocess
        date=time.strftime("%a %b %d %H:%M:%S %Z %Y", time.localtime(time.time()))
        title=self.test
        if self.color=='green':
            title+=' OK - '
        if (self.color=='yellow') or (self.color=='red'):
            title+=' Not OK - '
        if self.type=='data':
            report='%s %s.%s\n%s\n' % (self.type,self.hostname,self.test,'\n'.join(self.textarr))
        elif self.type=='client':
            report='%s %s.%s %s\n%s\n' % (self.type,self.hostname,self.test,self.hostclass,'\n'.join(self.textarr))
        else:
           report='%s %s.%s %s %s %s\n%s\n' % (self.type,self.hostname,self.test,self.color,date,title,'\n'.join(self.textarr))
        if ('BB' in os.environ) and ('BBDISP' in os.environ):
            proc = subprocess.Popen([os.environ['BB'], os.environ['BBDISP'],'@'],
                                    stdin=subprocess.PIPE,
                                   )
            proc.communicate(report)
        else:
            print(report)

    def moan(self,signal,frame):
        import time,sys
        date=time.strftime("%a %b %d %H:%M:%S %Z %Y", time.localtime(time.time()))
        msg=frame.f_code.co_name+' in '+frame.f_code.co_filename+' line '+str(frame.f_lineno)
        sys.stderr.write(date+' '+self.hostname+'.'+self.test+': '+msg+'\n')
        self.color_line('yellow','Warning: '+msg)
        sys.exit(2)

    def croak(self,signal,frame):
        import time,sys
        date=time.strftime("%a %b %d %H:%M:%S %Z %Y", time.localtime(time.time()))
        msg=frame.f_code.co_name+' in '+frame.f_code.co_filename+' line '+str(frame.f_lineno)
        sys.stderr.write(date+' '+self.hostname+'.'+self.test+': '+msg+'\n')
        self.color_line('red','Error: '+msg)
        self.send()
        sys.exit(1)

