//
//  PMAccountProtocol.h
//  planckMailiOS
//
//  Created by admin on 8/12/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#ifndef planckMailiOS_PMAccountProtocol_h
#define planckMailiOS_PMAccountProtocol_h

@protocol PMAccountProtocol <NSObject>
@property (nonatomic, copy) NSString * id;
@property (nonatomic, copy) NSString * namespace_id;
@property (nonatomic, copy) NSString * token;
@property (nonatomic, copy) NSString * account_id;
@end

#endif
