//
//  JWTagView.m
//  JWScrollPageView
//
//  Created by djw on 2016/11/9.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import "JWTagView.h"

@interface JWTagView() {
    
    CGSize  _titleSize;
    CGFloat _imageHeight;
    CGFloat _imageWidth;
    BOOL    _isShowImage; //默认不显示 为 NO
}
/**
 标签的图片
 */
@property (nonatomic, strong) UIImageView   *imageView;

/**
 标签 用 label，加上点击手势
 */
@property (nonatomic, strong) UILabel       *label;
@property (nonatomic, strong) UIView        *contentView;

@end

@implementation JWTagView

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.currentTransformSx = 1.0;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        _isShowImage = NO;
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 如果不显示图片，就让子控件 label 的 frame 为标签的 bounds
    if (!_isShowImage) {
        self.label.frame = self.bounds;
    }
}

- (void)adjustSubviewFrame {
    _isShowImage = YES;
    
    CGRect  contentViewFrame = self.bounds;
    // 根据文字的宽度修改 contentView 和 label 的 frame, 并且重新添加到标签上
    contentViewFrame.size.width = [self tagViewWidth];
    contentViewFrame.origin.x = (self.frame.size.width - contentViewFrame.size.width) / 2;
    self.contentView.frame = contentViewFrame;
    self.label.frame = self.contentView.bounds;
    // contentView 放到底层，label 和 image 放到 contemtView 上
    [self addSubview:self.contentView];
    [self.label removeFromSuperview];
    [self.contentView addSubview:self.label];
    [self.contentView addSubview:self.imageView];
    
    // 根据外部设定的图片位置 调整布局
    
    switch (self.imagePosition) {
        case TagImagePosotion_Top:
        {
            CGRect contentViewFrame = self.contentView.frame;
            contentViewFrame.size.height = _imageHeight + _titleSize.height;
            contentViewFrame.origin.y = (self.frame.size.height - contentViewFrame.size.height) / 2;
            self.contentView.frame = contentViewFrame;
            // 计算 imageview 的中心点
            self.imageView.frame = CGRectMake(0, 0, _imageWidth, _imageHeight);
            CGPoint center = self.imageView.center;
            center.x = self.label.center.x;
            self.imageView.center = center;
            //修改 label 的 frame
            CGFloat labelHeight = self.contentView.frame.size.height - _imageHeight;
            CGRect labelFrame = self.label.frame;
            labelFrame.origin.y = _imageHeight;
            labelFrame.size.height = labelHeight;
            self.label.frame = labelFrame;
            
            break;
        }
        case TagImagePosotion_Left:
        {
            CGRect labelFrame = self.label.frame;
            labelFrame.origin.x = _imageWidth;
            labelFrame.size.width = self.contentView.frame.size.width - _imageWidth;
            self.label.frame = labelFrame;
            
            CGRect imageFrame = CGRectZero;
            imageFrame.size.height = _imageHeight;
            imageFrame.size.width = _imageWidth;
            imageFrame.origin.y = (self.contentView.frame.size.height - imageFrame.size.height)/2;
            self.imageView.frame = imageFrame;
            
            break;
        }
        case TagImagePosotion_Right:
        {
            CGRect labelFrame = self.label.frame;
            labelFrame.size.width = self.contentView.frame.size.width - _imageWidth;
            self.label.frame = labelFrame;
            
            CGRect imageFrame = CGRectZero;
            imageFrame.origin.x = CGRectGetMaxX(self.label.frame);
            imageFrame.size.height = _imageHeight;
            imageFrame.size.width = _imageWidth;
            imageFrame.origin.y = (self.contentView.frame.size.height - imageFrame.size.height)/2;
            self.imageView.frame = imageFrame;
            
            break;
        }
        case TagImagePosotion_Center:
        {
            self.imageView.frame = self.contentView.bounds;
            [self.label removeFromSuperview];
            
            break;
        }
            
        default:
            break;
    }
}

- (CGFloat)tagViewWidth {
    CGFloat width = 0.0f;
    
    switch (self.imagePosition) {
        case TagImagePosotion_Left:
        {
            width = _imageWidth + _titleSize.width;
            break;
        }
        case TagImagePosotion_Right:
        {
            width = _imageWidth + _titleSize.width;
            break;
        }
        case TagImagePosotion_Center:
        {
            width = _imageWidth;
            break;
        }
        case TagImagePosotion_Top:
        {
            width = _titleSize.width;
            break;
        }
            
        default:
            break;
    }
    
    return width;
}

#pragma mark - setter  getter

- (void)setCurrentTransformSx:(CGFloat)currentTransformSx {
    _currentTransformSx = currentTransformSx;
    self.transform = CGAffineTransformMakeScale(currentTransformSx, currentTransformSx);
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    _imageWidth = normalImage.size.width;
    _imageHeight = normalImage.size.height;
    self.imageView.image = normalImage;
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    self.imageView.highlightedImage = selectedImage;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.label.font = font;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.label.textColor = textColor;
}

- (void)setText:(NSString *)text {
    _text = text;
    self.label.text = text;
    CGRect bounds = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.label.font} context:nil];
    _titleSize = bounds.size;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.imageView.highlighted = selected;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    return _imageView;
}

- (UILabel *)label {
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    
    return _label;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

@end
