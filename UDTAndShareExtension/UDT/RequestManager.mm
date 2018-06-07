//
//  RequestManager.m
//  UDTAndShareExtension
//
//  Created by peony on 2018/6/7.
//  Copyright © 2018年 peony. All rights reserved.
//

#import <iostream>
#import <netdb.h>
#import "RequestManager.h"
#import "udt.h"
#import "cc.h"
#import "test_util.h"

using namespace std;

//#ifndef WIN32
#ifndef WIN32
void* monitor(void* s)
#else
DWORD WINAPI monitor(LPVOID s)
#endif
{
    UDTSOCKET u = *(UDTSOCKET*)s;
    
    UDT::TRACEINFO perf;
    
    cout << "SendRate(Mb/s)\tRTT(ms)\tCWnd\tPktSndPeriod(us)\tRecvACK\tRecvNAK" << endl;
    
    while (true)
    {
#ifndef WIN32
        sleep(1);
#else
        Sleep(1000);
#endif
        
        if (UDT::ERROR == UDT::perfmon(u, &perf))
        {
            cout << "perfmon: " << UDT::getlasterror().getErrorMessage() << endl;
            break;
        }
        
        cout << perf.mbpsSendRate << "\t\t"
        << perf.msRTT << "\t"
        << perf.pktCongestionWindow << "\t"
        << perf.usPktSndPeriod << "\t\t\t"
        << perf.pktRecvACK << "\t"
        << perf.pktRecvNAK << endl;
    }
    
#ifndef WIN32
    return NULL;
#else
    return 0;
#endif
}

@implementation RequestManager

- (void)connectServerIp:(NSString *)server_ip port:(NSString *)port data:(NSData *)sendData{
    UDTUpDown _udt_;
    struct addrinfo hints, *local, *peer;
    memset(&hints, 0, sizeof(struct addrinfo));
    
    hints.ai_flags = AI_PASSIVE;
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    //hints.ai_socktype = SOCK_DGRAM;
    
    if (0 != getaddrinfo(NULL, "9000", &hints, &local))
    {
        cout << "incorrect network address.\n" << endl;
        return ;
    }
    
    UDTSOCKET client = UDT::socket(local->ai_family, local->ai_socktype, local->ai_protocol);
    
#ifndef WIN32
    UDT::setsockopt(client, 0, UDT_RENDEZVOUS, new bool(true), sizeof(bool));
#else
    UDT::setsockopt(client, 0, UDT_MSS, new int(1052), sizeof(int));
#endif
    
    if (UDT::ERROR == UDT::bind(client, local->ai_addr, local->ai_addrlen))
    {
        cout << "bind: " << UDT::getlasterror().getErrorMessage() << endl;
        return ;
    }
    
    freeaddrinfo(local);
    
    if (0 != getaddrinfo(server_ip.cString, port.cString, &hints, &peer))
    {
        cout << "incorrect server/peer address. " << server_ip.cString << ":" << port.cString << endl;
        return ;
    }
    
    // connect to the server, implict bind
    if (UDT::ERROR == UDT::connect(client, peer->ai_addr, peer->ai_addrlen))
    {
        cout << "connect: " << UDT::getlasterror().getErrorMessage() << endl;
        return ;
    }
    
    freeaddrinfo(peer);
    
    // using CC method
    //CUDPBlast* cchandle = NULL;
    //int temp;
    //UDT::getsockopt(client, 0, UDT_CC, &cchandle, &temp);
    //if (NULL != cchandle)
    //   cchandle->setRate(500);
//    int size = 100000;
//    char* data = new char[size];
    char *data = (char *)[sendData bytes];
    int size = strlen(data);
    
#ifndef WIN32
    pthread_create(new pthread_t, NULL, monitor, &client);
#else
    CreateThread(NULL, 0, monitor, &client, 0, NULL);
#endif
    
//    UDT::recv(<#UDTSOCKET u#>, <#char *buf#>, <#int len#>, <#int flags#>)
    
    for (int i = 0; i < 1000000; i ++)
    {
        int ssize = 0;
        int ss;
        while (ssize < size)
        {
            if (UDT::ERROR == (ss = UDT::send(client, data + ssize, size - ssize, 0)))
            {
                cout << "send:" << UDT::getlasterror().getErrorMessage() << endl;
                break;
            }
            
            ssize += ss;
        }
        
        if (ssize < size)
            break;
    }
    
    UDT::close(client);
    delete [] data;
}

@end
