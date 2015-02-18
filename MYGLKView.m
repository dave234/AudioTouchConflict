//
//  MYGLKView.m
//  AudioTouchConflict
//
//  Created by david oneill on 2/16/15.
//  Copyright (c) 2015 david oneill. All rights reserved.
//

#import "MYGLKView.h"

@implementation MYGLKView
{
    GLKMatrix4 _screenMatrixiOS;
    GLKVector4 drawColor;
    UIColor *_rectColor;
    GLKVector2 twotri[6];
    GLuint rectID;
    GLKBaseEffect *baseEffect;
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        //    context.isMultiThreaded = 1;
        self.context = context;
        [EAGLContext setCurrentContext:self.context];
        
        baseEffect = [[GLKBaseEffect alloc] init];
        glClearColor(0, 0, 0, 1.0f); // background color
        glEnableVertexAttribArray( GLKVertexAttribPosition);
        
        self.rectColor = [UIColor blueColor];
        
        twotri[0] = GLKVector2Make(0, 0);
        twotri[1] = GLKVector2Make(0, 100);
        twotri[2] = GLKVector2Make(100, 100);
        twotri[3] = GLKVector2Make(0, 0);
        twotri[4] = GLKVector2Make(100, 100);
        twotri[5] = GLKVector2Make(100, 0);
        
        glGenBuffers(1, &rectID);
        glBindBuffer(GL_ARRAY_BUFFER,rectID);
        glBufferData(GL_ARRAY_BUFFER, sizeof(GLKVector2) * 6, twotri, GL_STATIC_DRAW);
        glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(GLKVector2), NULL);
    }
    return self;
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _screenMatrixiOS = GLKMatrix4MakeScale(2.0 / frame.size.width,-2.0 / frame.size.height,1.0);
    _screenMatrixiOS.m30 = -1;
    _screenMatrixiOS.m31 = 1;
}

-(void)drawRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT);
    baseEffect.transform.projectionMatrix = GLKMatrix4Translate(_screenMatrixiOS, self.rectOrigin.x, self.rectOrigin.y, 0);
    baseEffect.constantColor = drawColor;
    [baseEffect prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, rectID);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(GLKVector2), NULL);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}
-(UIColor *)rectColor{
    
    return _rectColor;
}
-(void)setRectColor:(UIColor *)rectColor{
    CGFloat color[4];
    [rectColor getRed:&color[0] green:&color[1] blue:&color[2] alpha:&color[3]];
    _rectColor = rectColor;
    for (int i = 0; i < 4; i ++){
        drawColor.v[i] = color[i];
    }
}
@end
