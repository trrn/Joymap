//
//  DataSource.m
//  Joymap
//
//  Created by gli on 2013/10/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "DataSource.h"

#import <FMDatabase.h>
#import <FMDatabaseQueue.h>

static NSDate *_date;

@implementation DataSource

#pragma mark - private

+ (NSString *)dlPath
{
    static NSString *_path = nil;
    
    if (!_path) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
        _path = [paths[0] stringByAppendingPathComponent:JDB_FILE_NAME];
    }

    //DLog(@"%@", _path);

    return _path;
}

+ (NSString *)defPath
{
    static NSString *_path = nil;

    if (!_path) {
        NSArray *paths = [NSBundle.mainBundle pathsForResourcesOfType:@"jdb" inDirectory:nil];
        if (paths.count > 0) {
            DLog(@"default jdb file : %@", paths[0]);
            _path = paths[0];
            return _path;
        }
    }

    return _path;
}

+ (NSString *)path
{
    NSString *path = [FileUtil existsFile:self.dlPath] ? self.dlPath : self.defPath;
    
    if (!path) {
        DLog(@"db path is nil");
        return nil;
    }

    return path;
}

+ (FMDatabase *)open
{
    NSString *path = self.path;

    if (!path) {
        return nil;
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:path];

    if (![db open]) {
        FLog(@"cannot open %@. %@", path, [db lastError]);
        [db close];
        return nil;
    }
    return db;
}

+ (FMDatabaseQueue *)queue
{
    NSString *path = self.path;
    
    if (!path) {
        return nil;
    }
    
    FMDatabaseQueue *db = [FMDatabaseQueue databaseQueueWithPath:path];

    if (!db) {
        FLog(@"no %@", JDB_FILE_NAME);
        return nil;
    }

    return db;
}

+ (void)validateSqliteFile:(NSString *)path
{
    FMDatabase *db = [FMDatabase databaseWithPath:path];

    if (!db) {
        @throw Err(@"not db file. %@", path);
    }

    @try {
        if (![db open]) {
            @throw Err(@"cannot open %@. %@", path, db.lastError);
        }
        
        if (![db goodConnection]) {
            @throw Err(@"cannot connect db");
        }
    }
    @finally {
        [db close];
    }
}

+ (id)select:(FMDatabase *)db ret:(id)ret exe:(FMResultSet *(^)(FMDatabase *))exe
         map:(BOOL(^)(FMResultSet *, id))map
{
    FMResultSet *rs = nil;

    rs = exe(db);
    if (!rs)
        @throw Err(@"rs is nil");

    while ([rs next]) {
        if (!map(rs, ret)) {
            break;
        }
    }

    return ret;
}

+ (id)select:(id)ret exe:(FMResultSet *(^)(FMDatabase *))exe
         map:(BOOL(^)(FMResultSet *, id))map
{
    FMDatabase *db = nil;

    @try {
        db = [self open];
        [self select:db ret:ret exe:exe map:map];
    }
    @catch (NSException *e) {
        ELog(@"%@. %@", [db lastError], e);
    }
    @finally {
        [db close];
    }
    return ret;
}

+ (BOOL)exists:(NSString *)sql key:(id)key db:(FMDatabase *)db
{
    NSMutableArray *ret = @[@(NO)].mutableCopy;

    [self select:db ret:ret exe:^(FMDatabase *db) {
        return [db executeQuery:sql, key];
    } map:^(FMResultSet *rs, id ret) {
        ret[0] = @(YES);
        return NO;
    }];

    return [ret[0] boolValue];
}

#pragma mark - public

+ (NSArray *)pinsOrderBy:(NSString *)sort
{
    NSMutableArray *ret = @[].mutableCopy;
    
    return [self select:ret exe:^(FMDatabase *db) {
        return [db executeQuery:[NSString stringWithFormat:@"select * from pin order by %@", sort]];
    } map:^(FMResultSet *rs, id ret) {
        Pin *p = Pin.new;
        p.id = [rs intForColumn:@"_id"];
        p.latitude = [rs doubleForColumn:@"latitude"];
        p.longitude = [rs doubleForColumn:@"longitude"];
        p.name = [rs stringForColumn:@"name"];
        p.kategoryId = [rs intForColumn:@"category_id"];
        [ret addObject:p];
        return YES;
    }];
}

+ (NSArray *)pinsOrderByID:(BOOL)asc
{
    return (asc ? [self pinsOrderBy:@"_id"] : [self pinsOrderBy:@"_id desc"]);
}

+ (NSArray *)pinsOrderByName:(BOOL)asc
{
    return (asc ? [self pinsOrderBy:@"name"] : [self pinsOrderBy:@"name desc"]);
}

+ (NSArray *)pinsOrderByDistanceFrom:(CLLocationCoordinate2D *)co;
{
    if (!co) {
        return self.pins;
    }

    CLLocation *from = [CLLocation.alloc initWithLatitude:co->latitude longitude:co->longitude];

    return [self.pins sortedArrayUsingComparator:^(id obj1, id obj2) {

        Pin *p1 = obj1;
        Pin *p2 = obj2;

        CLLocation *l1 = [CLLocation.alloc initWithLatitude:p1.latitude longitude:p1.longitude];
        CLLocation *l2 = [CLLocation.alloc initWithLatitude:p2.latitude longitude:p2.longitude];

        CLLocationDistance d1 = [from distanceFromLocation:l1];
        CLLocationDistance d2 = [from distanceFromLocation:l2];

        if (d1 > d2)
            return (NSComparisonResult)NSOrderedDescending;

        if (d1 < d2)
            return (NSComparisonResult)NSOrderedAscending;
        
        return (NSComparisonResult)NSOrderedSame;
    }];
}

+ (NSArray *)pins
{
    return [self pinsOrderByID:YES];
}

+ (Pin *)pinByID:(NSInteger)iD;
{
    NSMutableArray *ret = @[].mutableCopy;

    ret = [self select:ret exe:^(FMDatabase *db) {
        return [db executeQueryWithFormat:@"select * from pin where _id = %d", iD];
    } map:^(FMResultSet *rs, id ret) {
        Pin *p = Pin.new;
        p.id = [rs intForColumn:@"_id"];
        p.latitude = [rs doubleForColumn:@"latitude"];
        p.longitude = [rs doubleForColumn:@"longitude"];
        p.name = [rs stringForColumn:@"name"];
        p.kategoryId = [rs intForColumn:@"category_id"];
        [ret addObject:p];
        return NO;
    }];

    return ret.firstObject;
}

+ (NSMutableArray *)layouts:(Pin *)pin
{
    NSMutableArray *ret = @[].mutableCopy;

    return [self select:ret exe:^(FMDatabase *db) {
        return [db executeQueryWithFormat:@"select * from layout where pin_id = %d order by orderno", pin.id];
    } map:^(FMResultSet *rs, id ret) {
        Layout *p = Layout.new;
        p.id = [rs intForColumn:@"_id"];
        p.pinId = [rs intForColumn:@"pin_id"];
        p.kind = [rs intForColumn:@"kind"];
        p.orderNo = [rs intForColumn:@"orderno"];
        [ret addObject:p];
        return YES;
    }];
}

+ (NSMutableArray *)items:(Layout *)layout
{
    NSMutableArray *ret = @[].mutableCopy;

    return [self select:ret exe:^(FMDatabase *db) {
        return [db executeQueryWithFormat:@"select a.*, b._id as layoutItemId, b.layout_id, b.orderno"
                " from item a, layout_item b"
                " where a._id = b.item_id and b.layout_id = %d order by b.orderno", layout.id];
    } map:^(FMResultSet *rs, id ret) {
        Item *p = Item.new;
        p.id = [rs intForColumn:@"_id"];
        p.type = [rs intForColumn:@"type"];
        p.resource1 = [rs stringForColumn:@"resource1"];
        p.resource2 = [rs dataForColumn:@"resource2"];
        p.layoutItemId = [rs intForColumn:@"layoutItemId"];
        p.layoutId = [rs intForColumn:@"layout_id"];
        p.orderNo = [rs intForColumn:@"orderno"];
        [ret addObject:p];
        return YES;
    }];
}

+ (Item *)itemForSubtitle:(Pin *)pin
{
    NSMutableArray *ret = @[].mutableCopy;

    return [[self select:ret exe:^(FMDatabase *db) {
        return [db executeQueryWithFormat:
            @"select d.resource1 from pin a, layout b, layout_item c, item d"
             " where a._id = b.pin_id and b._id = c.layout_id and c.item_id = d._id"
             " and a._id = %d and d.type in (1) order by b.orderno, c.orderno limit 1"
                , pin.id];
    } map:^(FMResultSet *rs, id ret) {
        Item *p = Item.new;
        p.resource1 = [rs stringForColumn:@"resource1"];
        [ret addObject:p];
        return NO;
    }] firstObject];
}

+ (Item *)itemForThumbnail:(Pin *)pin
{
    NSMutableArray *ret = @[].mutableCopy;
    
    return [[self select:ret exe:^(FMDatabase *db) {
        return [db executeQueryWithFormat:
                @"select d.* from pin a, layout b, layout_item c, item d"
                " where a._id = b.pin_id and b._id = c.layout_id"
                " and c.item_id = d._id and a._id = %d and d.type in (2, 3, 7)"
                " order by b.orderno, c.orderno limit 1"
                , pin.id];
    } map:^(FMResultSet *rs, id ret) {
        Item *p = Item.new;
        p.id = [rs intForColumn:@"_id"];
        p.type = [rs intForColumn:@"type"];
        p.resource1 = [rs stringForColumn:@"resource1"];
        p.resource2 = [rs dataForColumn:@"resource2"];
        [ret addObject:p];
        return NO;
    }] firstObject];
}

#pragma mark - update

+ (void)saveLayoutItem:(Item *)item db:(FMDatabase *)db
{
    if (item.layoutItemId > 0) {
        if ([self exists:@"select * from layout_item where _id = ?" key:@(item.layoutItemId) db:db]) {
            if (![db executeUpdate:
                  @"update layout_item set layout_id = %d, item_id = %d, orderno = %d where _id = %d",
                  item.layoutId, item.id, item.orderNo, item.layoutItemId])
                @throw Err(@"%@", [db lastError]);
        } else {
            if (![db executeUpdateWithFormat:
                  @"insert into layout_item values( %d, %d, %d, %d )",
                  item.layoutItemId, item.layoutId, item.id, item.orderNo])
                @throw Err(@"%@", [db lastError]);
        }
    } else {
        if (![db executeUpdateWithFormat:
              @"insert into layout_item values( null, %d, %d, %d )",
              item.layoutId, item.id, item.orderNo])
            @throw Err(@"%@", [db lastError]);

        [self select:db ret:item exe:^(FMDatabase *db) {
            return [db executeQuery:
                    @"select _id from layout_item where rowid = last_insert_rowid()"];
        } map:^(FMResultSet *rs, id p) {
            Item *item = p;
            item.layoutItemId = [rs intForColumn:@"_id"];
            return NO;
        }];
    }
}

+ (void)saveItem:(Item *)item db:(FMDatabase *)db
{
    [item beforeSave];

    if (item.id > 0) {
        if ([self exists:@"select * from item where _id = ?" key:@(item.id) db:db]) {
            if (![db executeUpdate:
                  @"update item set type = ?, resource1 = ?, resource2 = ? where _id = ?",
                  @(item.type), item.resource1, item.resource2, item.id])
                @throw Err(@"%@", [db lastError]);
        } else {
            if (![db executeUpdate:
                  @"insert into item values( ?, ?, ?, ? )",
                  @(item.id), @(item.type), item.resource1, item.resource2])
                @throw Err(@"%@", [db lastError]);
        }
    } else {
        if (![db executeUpdate:
              @"insert into item values( null, ?, ?, ? )",
              @(item.type), item.resource1, item.resource2])
            @throw Err(@"%@", [db lastError]);

        [self select:db ret:item exe:^(FMDatabase *db) {
            return [db executeQuery:
                    @"select _id from item where rowid = last_insert_rowid()"];
        } map:^(FMResultSet *rs, id p) {
            Item *item = p;
            item.id = [rs intForColumn:@"_id"];
            return NO;
        }];
    }
}

+ (void)saveItems:(Pin *)pin db:(FMDatabase *)db
{
    for (Layout *lay in pin.layouts) {
        for (Item *item in lay.items) {
            [self saveItem:item db:db];
            [self saveLayoutItem:item db:db];
        }
    }
}

+ (void)saveLayout:(Layout *)lay db:(FMDatabase *)db
{
    [lay beforeSave];

    if (lay.id > 0) {
        if ([self exists:@"select * from layout where _id = ?" key:@(lay.id) db:db]) {
            if (![db executeUpdate:
                  @"update layout set pin_id = %d, kind = %d, orderno = %d where _id = %d",
                  lay.pinId, lay.kind, lay.orderNo, lay.id])
                @throw Err(@"%@", [db lastError]);
        } else {
            if (![db executeUpdateWithFormat:
                  @"insert into layout values( %d, %d, %d, %d )",
                  lay.id, lay.pinId, lay.kind, lay.orderNo])
                @throw Err(@"%@", [db lastError]);
        }
    } else {
        if (![db executeUpdateWithFormat:
              @"insert into layout values( null, %d, %d, %d )",
              lay.pinId, lay.kind, lay.orderNo])
            @throw Err(@"%@", [db lastError]);
        
        [self select:db ret:lay exe:^(FMDatabase *db) {
            return [db executeQuery:
                    @"select _id from layout where rowid = last_insert_rowid()"];
        } map:^(FMResultSet *rs, id p) {
            Layout *lay = p;
            lay.id = [rs intForColumn:@"_id"];
            return NO;
        }];
    }
}

+ (void)saveLayouts:(Pin *)pin db:(FMDatabase *)db
{
    for (Layout *lay in pin.layouts) {
        lay.pinId = pin.id;
        [self saveLayout:lay db:db];
    }
}

+ (void)savePin:(Pin *)pin db:(FMDatabase *)db
{
    [pin beforeSave];

    if (pin.id > 0) {
        if ([self exists:@"select * from pin where _id = ?" key:@(pin.id) db:db]) {
            if (![db executeUpdate:
                  @"update pin set latitude = %f, longitude = %f, name = %@, category_id = %d where _id = %d",
                  pin.latitude, pin.longitude, pin.name, pin.kategoryId, pin.id])
                @throw Err(@"%@", [db lastError]);
        } else {
            if (![db executeUpdateWithFormat:
                  @"insert into pin values( %d, %f, %f, %@, %d )",
                  pin.id, pin.latitude, pin.longitude, pin.name, pin.kategoryId])
                @throw Err(@"%@", [db lastError]);
        }
    } else {
        if (![db executeUpdateWithFormat:
              @"insert into pin values( null, %f, %f, %@, %d )",
              pin.latitude, pin.longitude, pin.name, pin.kategoryId])
            @throw Err(@"%@", [db lastError]);

        [self select:db ret:pin exe:^(FMDatabase *db) {
            return [db executeQuery:
                    @"select _id from pin where rowid = last_insert_rowid()"];
        } map:^(FMResultSet *rs, id p) {
            Pin *pin = p;
            pin.id = [rs intForColumn:@"_id"];
            return NO;
        }];
    }
}

+ (void)deleteItems:(Pin *)pin db:(FMDatabase *)db
{
    // delete item unless another pin references the item

    if (![db executeUpdateWithFormat:
            @"delete from item where _id in"
             " ( select"
             "    e._id"
             "  from"
             "    layout a, layout_item b, item e"
             "  where"
             "    a.pin_id = %d and a._id = b.layout_id and"
             "    b.item_id = e._id and not exists"
             "    ( select"
             "        'x'"
             "      from"
             "        layout a1, layout_item b1"
             "      where"
             "        a1.pin_id <> %d and"
             "        a1._id = b1.layout_id and"
             "        b1.item_id = e._id"
             "    )"
             ")", pin.id, pin.id])
        @throw Err(@"%@", [db lastError]);
}

+ (void)deleteLayouts:(Pin *)pin db:(FMDatabase *)db
{
    if (![db executeUpdateWithFormat:@"delete from layout where pin_id = %d", pin.id])
        @throw Err(@"%@", [db lastError]);
}

+ (void)deletePin:(Pin *)pin db:(FMDatabase *)db
{
    if (![db executeUpdateWithFormat:@"delete from pin where _id = %d", pin.id])
        @throw Err(@"%@", [db lastError]);
}

+ (id)transaction:(id)dat exe:(void (^)(FMDatabase *db, BOOL *rollback, id copy, BOOL *ok))exe
{
    __block BOOL ok = NO;
    FMDatabaseQueue *queue = nil;

    id copy = [dat copy];

    @try {
        queue = self.queue;
        if (!queue)
            @throw Err(@"queue is nil");

        [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            @try {
                exe(db, rollback, copy, &ok);
            }
            @catch (NSException *e) {
                ELog(@"%@. rollback", e);
                *rollback = YES;
                return;     // do not throw
            }
        }];
    }
    @catch (NSException *e) {
        ELog(@"%@", e);
    }
    @finally {
        [queue close];
    }

    if (ok)
        return copy;

    return nil;
}

+ (id)save:(id)pin
{
    return [self transaction:pin exe:^(FMDatabase *db, BOOL *rollback, id copy, BOOL *ok) {
        [self deleteItems:  copy db:db];
        [self deleteLayouts:copy db:db];
        [self deletePin:    copy db:db];
        [self savePin:      copy db:db];
        [self saveLayouts:  copy db:db];
        [self saveItems:    copy db:db];

        [self needReload];
        *ok = YES;
    }];
}

+ (id)delete:(id)pin
{
    return [self transaction:pin exe:^(FMDatabase *db, BOOL *rollback, id copy, BOOL *ok) {
        [self deleteItems:  copy db:db];
        [self deleteLayouts:copy db:db];
        [self deletePin:    copy db:db];

        [self needReload];
        *ok = YES;
    }];
}

#pragma mark - etc

+ (void)needReload;
{
    _date = NSDate.date;
}

+ (NSDate *)updatedDate
{
    return _date;
}

@end
