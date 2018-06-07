//
//  CycleScrollView.m
//  CycleScrollDemo
//
//  Created by Weever Lu on 12-6-14.
//  Copyright (c) 2012年 linkcity. All rights reserved.
//

#import "CycleScrollView.h"


@implementation CycleScrollView

- (id)initWithFrame:(CGRect)frame cycleDirection:(CycleDirection)direction pictures:(NSArray *)pictureArray
{
    self = [super initWithFrame:frame];
    if(self)
    {
        scrollFrame = frame;
        scrollDirection = direction;
        totalPage = pictureArray.count;
        curPage = 1;                                    // 显示的是图片数组里的第一张图片
        curImages = [[NSMutableArray alloc] init];
        imagesArray = [[NSArray alloc] initWithArray:pictureArray];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(scrollFrame), CGRectGetHeight(scrollFrame))];
        scrollView.backgroundColor = [UIColor blackColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        
        
        pageControl = [[UIPageControl alloc] init];
        CGSize pageSize = [pageControl sizeForNumberOfPages:totalPage];
        pageControl.frame = CGRectMake(CGRectGetWidth(frame) / 2 - pageSize.width / 2, CGRectGetHeight(frame) - pageSize.height, pageSize.width, pageSize.height);
        pageControl.numberOfPages = totalPage;
        pageControl.currentPage = curPage - 1;
        [self addSubview:pageControl];
        
        // 在水平方向滚动
        if(scrollDirection == CycleDirectionLandscape) {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3,
                                                scrollView.frame.size.height);
        }
        // 在垂直方向滚动 
        if(scrollDirection == CycleDirectionPortait) {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,
                                                scrollView.frame.size.height * 3);
        }
        [self refreshScrollView];
    }
    
    return self;
}
- (void)resetScrollViewImages:(NSArray *)pictureArray {
    totalPage = pictureArray.count;
    curPage = 1;                                    // 显示的是图片数组里的第一张图片
    curImages = [[NSMutableArray alloc] init];
    imagesArray = [[NSArray alloc] initWithArray:pictureArray];
    
    CGSize pageSize = [pageControl sizeForNumberOfPages:totalPage];
    pageControl.frame = CGRectMake(CGRectGetWidth(self.frame) / 2 - pageSize.width / 2, CGRectGetHeight(self.frame) - pageSize.height, pageSize.width, pageSize.height);
    pageControl.numberOfPages = totalPage;
    pageControl.currentPage = curPage - 1;
    
    [self getDisplayImagesWithCurpage:curPage];
    UIImageView *firstImageView = [scrollView viewWithTag:1000];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *showImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self->curImages objectAtIndex:0]]]];//[curImages objectAtIndex:i];
        UIImage *image = [self scaleImage:showImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            firstImageView.image = image;
        });
    });
    UIImageView *secondImageView = [scrollView viewWithTag:1001];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *showImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self->curImages objectAtIndex:1]]]];//[curImages objectAtIndex:i];
        UIImage *image = [self scaleImage:showImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            secondImageView.image = image;
        });
    });
    UIImageView *thirdImageView = [scrollView viewWithTag:1002];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *showImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self->curImages objectAtIndex:2]]]];//[curImages objectAtIndex:i];
        UIImage *image = [self scaleImage:showImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            thirdImageView.image = image;
        });
    });
    
    [self refreshScrollView];
}

- (void)refreshPageControl {
    pageControl.currentPage = curPage - 1;
}

- (void)refreshScrollView {
    [self refreshPageControl];
    scrollView.scrollEnabled = imagesArray.count != 1;
    
    [self getDisplayImagesWithCurpage:curPage];
    if (curImages.count == 0) {
        return;
    }
    @synchronized(self) {
       NSArray *subViews = [scrollView subviews];
        if([subViews count] == 0) {
            //        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            for (int i = 0; i < 3; i++) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(scrollFrame), CGRectGetHeight(scrollFrame))];
                imageView.tag = 1000 + i;
                imageView.userInteractionEnabled = YES;
                imageView.backgroundColor = [UIColor whiteColor];
                //[imageView sd_setImageWithURL:[NSURL URLWithString:[curImages objectAtIndex:i]]];
                //imageView.image = [][curImages objectAtIndex:i];
                if (i == 1) {
                    NSString *urlString = [curImages objectAtIndex:i];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        UIImage *showImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];//[curImages objectAtIndex:i];
                        UIImage *image = [self scaleImage:showImage];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imageView.image = image;
                        });
                    });
                }
                
                /*
                 UIViewContentModeScaleToFill,
                 UIViewContentModeScaleAspectFit,      // contents scaled to fit with fixed aspect. remainder is transparent
                 UIViewContentModeScaleAspectFill,     // contents scaled to fill with fixed aspect. some portion of content may be clipped.
                 UIViewContentModeRedraw,              // redraw on bounds change (calls -setNeedsDisplay)
                 UIViewContentModeCenter,              // contents remain same size. positioned adjusted.
                 UIViewContentModeTop,
                 UIViewContentModeBottom,
                 UIViewContentModeLeft,
                 UIViewContentModeRight,
                 UIViewContentModeTopLeft,
                 UIViewContentModeTopRight,
                 UIViewContentModeBottomLeft,
                 UIViewContentModeBottomRight,
                 */
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleTap:)];
                [imageView addGestureRecognizer:singleTap];
                
                //设置位置
                // 水平滚动
                if(scrollDirection == CycleDirectionLandscape) {
                    imageView.frame = CGRectOffset(imageView.frame, scrollFrame.size.width * i, 0);
                }
                // 垂直滚动
                if(scrollDirection == CycleDirectionPortait) {
                    imageView.frame = CGRectOffset(imageView.frame, 0, scrollFrame.size.height * i);
                }
                
                [scrollView addSubview:imageView];
            }
        }else {
            // 水平滚动
            if(scrollDirection == CycleDirectionLandscape) {
                int x = scrollView.contentOffset.x;
                // 往下翻一张
                UIImageView *firstImageView = [scrollView viewWithTag:1000];
                UIImageView *secondImageView = [scrollView viewWithTag:1001];
                UIImageView *thirdImageView = [scrollView viewWithTag:1002];
                if(x >= (2*scrollFrame.size.width)) {
                    firstImageView.image = secondImageView.image;
                    secondImageView.image = thirdImageView.image;
                    [self resetScrollViewContentOffset];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        UIImage *showImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self->curImages objectAtIndex:2]]]];//[curImages objectAtIndex:i];
                        UIImage *image = [self scaleImage:showImage];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            thirdImageView.image = image;
                        });
                    });
                }
                if(x <= 0) {
                    UIImage *secondImage = secondImageView.image;
                    secondImageView.image = firstImageView.image;
                    [self resetScrollViewContentOffset];
                    thirdImageView.image = secondImage;
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        UIImage *showImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self->curImages objectAtIndex:0]]]];//[curImages objectAtIndex:i];
                        UIImage *image = [self scaleImage:showImage];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            firstImageView.image = image;
                        });
                    });
                }
            }
            
            // 垂直滚动
            if(scrollDirection == CycleDirectionPortait) {
                int y = scrollView.contentOffset.y;
                // 往下翻一张
                UIImageView *firstImageView = [scrollView viewWithTag:1000];
                UIImageView *secondImageView = [scrollView viewWithTag:1001];
                UIImageView *thirdImageView = [scrollView viewWithTag:1002];
                if(y >= 2 * (scrollFrame.size.height)) {
                    firstImageView.image = secondImageView.image;
                    secondImageView.image = thirdImageView.image;
                    [self resetScrollViewContentOffset];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        UIImage *showImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self->curImages objectAtIndex:2]]]];//[curImages objectAtIndex:i];
                        UIImage *image = [self scaleImage:showImage];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            thirdImageView.image = image;
                        });
                    });
                }
                if(y <= 0) {
                    UIImage *secondImage = secondImageView.image;
                    secondImageView.image = firstImageView.image;
                    [self resetScrollViewContentOffset];
                    thirdImageView.image = secondImage;
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        UIImage *showImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self->curImages objectAtIndex:0]]]];//[curImages objectAtIndex:i];
                        UIImage *image = [self scaleImage:showImage];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            firstImageView.image = image;
                        });
                    });
                }
            }
        }
        
        [self resetScrollViewContentOffset];
    }
    
    
}
- (void)resetScrollViewContentOffset {
    if (scrollDirection == CycleDirectionLandscape) {
        [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0)];
    }
    if (scrollDirection == CycleDirectionPortait) {
        [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height)];
    }
}
- (NSArray *)getDisplayImagesWithCurpage:(int)page {
    
    int pre = [self validPageValue:curPage-1];
    int last = [self validPageValue:curPage+1];
    
    if([curImages count] != 0) [curImages removeAllObjects];
    
    if (imagesArray.count > 0) {
        [curImages addObject:[imagesArray objectAtIndex:pre-1]];
        [curImages addObject:[imagesArray objectAtIndex:curPage-1]];
        [curImages addObject:[imagesArray objectAtIndex:last-1]];
    }
    
    return curImages;
}

- (int)validPageValue:(NSInteger)value {
    
    if(value == 0) value = totalPage;                   // value＝1为第一张，value = 0为前面一张
    if(value == totalPage + 1) value = 1;
    
    return value;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    int x = aScrollView.contentOffset.x;
    int y = aScrollView.contentOffset.y;
    NSLog(@"did  x=%d  y=%d", x, y);
    
    // 水平滚动
    if(scrollDirection == CycleDirectionLandscape) {
        // 往下翻一张
        if(x >= (2*scrollFrame.size.width)) { 
            curPage = [self validPageValue:curPage+1];
            [self refreshScrollView];
        }
        if(x <= 0) {
            curPage = [self validPageValue:curPage-1];
            [self refreshScrollView];
        }
    }
    
    // 垂直滚动
    if(scrollDirection == CycleDirectionPortait) {
        // 往下翻一张
        if(y >= 2 * (scrollFrame.size.height)) { 
            curPage = [self validPageValue:curPage+1];
            [self refreshScrollView];
        }
        if(y <= 0) {
            curPage = [self validPageValue:curPage-1];
            [self refreshScrollView];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(cycleScrollViewDelegate:didScrollImageView:)]) {
        [self.delegate cycleScrollViewDelegate:self didScrollImageView:curPage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    int x = aScrollView.contentOffset.x;
    int y = aScrollView.contentOffset.y;
    
    NSLog(@"--end  x=%d  y=%d", x, y);
    
    if (scrollDirection == CycleDirectionLandscape) {
        [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0) animated:YES];
    }
    if (scrollDirection == CycleDirectionPortait) {
        [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height) animated:YES];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([self.delegate respondsToSelector:@selector(cycleScrollViewDelegate:didSelectImageView:)]) {
        [self.delegate cycleScrollViewDelegate:self didSelectImageView:curPage];
    }
}

/*
 使用压缩的原因：当加载相册图片，或加载拍照图片的时候，这时的图片都是原图，因为原图像素比较高，图片质量比较好，图片的体量比较大。但是有没有想过，手机上可能根本不需要这样的高清图片，这是的几张图片可能就能使app被杀掉。那么我们可不可以牺牲图片的清晰度，来使内存占用降低呢。当然可以，经过实际测试，把图片根据手机屏幕等比缩小，然后利用JPEG有损压缩，压缩比例0.5左右，可以百倍千倍的缩小内存占用。当然在手机上看到的图片和原图，在不缩放的情况下没有明显的区别。
 */
//图片压缩
- (UIImage *)scaleImage:(UIImage *)image {
    //实现等比例缩放
    CGFloat screnWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screnHeight =CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat hfactor = image.size.width / screnWidth;
    CGFloat vfactor = image.size.height / screnHeight;
    CGFloat factor = fmax(hfactor, vfactor);
    //画布大小
    CGFloat newWith = image.size.width / factor;
    CGFloat newHeigth = image.size.height / factor;
    CGSize newSize = CGSizeMake(newWith, newHeigth);//CGSize(width: newWith, height: newHeigth)
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newWith, newHeigth)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //图像压缩
    NSData *newImageData = UIImageJPEGRepresentation(newImage, 0.5);
    return [UIImage imageWithData:newImageData];
}

@end
