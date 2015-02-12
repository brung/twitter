//
//  MenuCell.m
//  twitter
//
//  Created by Bruce Ng on 2/11/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "MenuCell.h"

@interface MenuCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *menuItemLabel;

@end

@implementation MenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMenuItem:(MenuItem *)item {
    _menuItem = item;
    [self.iconImage setImage:[UIImage imageNamed:self.menuItem.iconImage]];
    self.menuItemLabel.text = self.menuItem.itemLabel;
}
@end
