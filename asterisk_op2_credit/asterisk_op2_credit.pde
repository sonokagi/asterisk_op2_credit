//---------------------------------------------------------------------
// 学園都市アスタリスク２期オープニングのクレジット表示を真似してみた
//---------------------------------------------------------------------
// - Processing 3.5.4 で作成
// - 実行後に何かキーを押すと再アニメーションします

PFont font_;
HexagonLine hline_;
CyberText[] ctext_;

void setup(){
  size(640,480);
  // 各クラスの初期化
  font_ = createFont("Meiryo", 32);
  hline_ = new HexagonLine(16, 17);
  ctext_ = new CyberText[3];
  for (int i = 0; i < ctext_.length; i++ ) {
    ctext_[i] = new CyberText();
  }
  // アニメーション開始
  startAnimation();
}

void draw(){
  background(0,0,0);
  
  // にぎやかしで、３か所くらいに同じクレジットを描画
  pushMatrix();
  translate( 50,100);
  drawCredit();
  popMatrix();
  
  pushMatrix();
  translate(150,350);
  drawCredit();
  popMatrix();
  
  pushMatrix();
  translate(350,200);
  drawCredit();
  popMatrix();
}

// クレジット描画
void drawCredit() {
  // テキスト
  textFont(font_);
  fill(185,255,255);
  textAlign(LEFT, CENTER);
  textSize(18);
  ctext_[0].setText("Programming language");
  ctext_[0].draw(20,-30);
  textSize(36);
  ctext_[1].setText("Processing");
  ctext_[1].draw(20,5);
  textSize(12);
  ctext_[2].setText("initiated by Ben Fry and Casey Reas.");
  ctext_[2].draw(20,45);
  
  // 6角形
  hline_.draw();
}

// 何かキーを押したら、アニメーションを開始
void keyPressed(){
  startAnimation();
}

void startAnimation() {
  // テキストのアニメーション開始(待ち時間、表示期間)
  ctext_[0].start(  0,200);
  ctext_[1].start(200,250);
  ctext_[2].start(500,150);
  
  // 6角形のアニメーション開始(待ち時間、各6角形の表示間隔)
  hline_.start(150, 15);
}

// 6角形クラス(アニメーション付き)
class Hexagon {
  float x_;
  float y_;
  float size_;
  boolean enable_ = true;
  int time_start_ = 0;
  int time_disp_  = 0;
  int time_hide_  = 0;
  int time_end_   = 0;
  
  Hexagon(float x, float y, float size) {
    x_ = x;
    y_ = y;
    size_ = size;
  }
  
  void display(boolean enable) {
    enable_ = enable; 
  } 
  
  // アニメーション開始
  // delay_ms      表示開始までの遅延
  // priod_show_ms 表示期間
  // priod_hide_ms 消滅表示の期間 
  void start(int delay_ms, int priod_show_ms, int priod_hide_ms ) {
    time_start_ = millis();
    time_disp_  = delay_ms;                     // 表示開始
    time_hide_  = time_disp_  + priod_show_ms;  // 表示完了(消滅表示開始)
    time_end_   = time_hide_  + priod_hide_ms;  // 消滅表示完了(非表示)
  }
  
  void draw() {
    // 描画禁止なら何もしない
    if ( !enable_ ) return;
    
    // 開始指示からの経過時間を取得
    int time = millis() - time_start_;
    
    // 指定時間まで何も表示しない
    if ( time < time_disp_ ) {
    }
    // 6角形表示(塗りつぶしあり、グローぽい表現)
    else if (time < time_hide_ ) {
      stroke(92,128,128,100);
      fill(44,104,96,100);
      glowhexagon(x_, y_, size_);
    }
    // 6角形の消滅表現(外形のみ表示)
    else if (time < time_end_ ) {
      stroke(255,255,255,192);
      noFill();
      strokeWeight(1.0f);
      hexagon(x_, y_, size_);
    }
    // 指定時間経過で消す(非表示)
    else {
    }
  }
  
  // ブレンドしながらの重ね書きで、グローぽい表現
  // --------------------------------------------------------------------------
  // https://note.com/deconbatch/n/nadd699e04580
  // [deconbatch]さん - ぼんやり光る効果を出す簡単な方法 その2 : Processing Tips
  // --------------------------------------------------------------------------
  void glowhexagon(float x, float y, float size) {
    blendMode(SCREEN);
    for ( int i = 0; i < 6; i++ ) {
      strokeWeight(2.0f*i);
      hexagon( x, y, size);
    }
    blendMode(BLEND);  
  }
  
  // 単純な6角形描画
  void hexagon(float x, float y, float size){ 
    beginShape();
    for ( int i = 0; i < 6; i++ ) {
      float rad = 2*PI*i/6 + PI/2;
      vertex(x + size * cos(rad), y + size * sin(rad));
    }
    endShape(CLOSE);
  }
}

// 6角形をライン状にスキャンしてアニメーションするクラス
class HexagonLine {
  Hexagon[] hex_;
  
  HexagonLine(float size, int n) {
    hex_ = new Hexagon[n];
    // 6角形を互い違いのライン上に配置(下記イメージ)
    // 0 2 4 ・・・ 
    //  1 3 5 ・・・
    float hexagon_width = size*sqrt(3);
    for ( int i = 0; i < hex_.length; i++ ) {
      if ( i%2 == 0 ) {
        hex_[i] = new Hexagon( i*hexagon_width/2, 0,        size);
      } else {
        hex_[i] = new Hexagon( i*hexagon_width/2, size*1.5, size);
      }
    }
    // 3～6個の頻度で表示しない6角形を設定
    // 見た目上、最初と最後の1個は消さないようループから除外(初期値の +1 と 終了条件の -1 の部分)
    for( int i = int(random(3,6)) + 1; i < (hex_.length - 1); i+=int(random(3,6)) ) {
      hex_[i].display(false);
    }
  }
  
  // アニメーション開始
  // delay_ms    表示開始までの遅延
  // interval_ms 各6角形の表示間隔 
  void start(int delay_ms, int interval_ms) {
    for ( int i = 0; i < hex_.length; i++ ) {
      hex_[i].start(delay_ms + interval_ms * i, 80, 50);
    }
  }
  
  void draw() {
    for ( int i = 0; i < hex_.length; i++ ) {
      hex_[i].draw();
    }
  }
}

// サイバーテキスト表示
// --------------------------------------------------------------------------
// http://kougaku-navi.net/backyard/
// [工学ナビ]さん - Watch Dogs Profiler に含まれる CyberText.pde を改造
// --------------------------------------------------------------------------
class CyberText {
  final String RANDOM_CHAR = "!#$%&=~|QWERTYUIOP`ASDFGHJKL+*ZXCVBNM<>?_";
  
  String text_ = "";  
  int time_start_ = -1;
  int time_disp_  = 0;
  int priod_      = 0;

  void setText(String text) {
    text_ = text;
  }

  // アニメーション開始
  // delay_ms 表示開始までの遅延
  // priod_ms テキストの表示開始から完了までの期間 
  void start(int delay_ms, int priod_ms) {
    time_start_  = millis();
    time_disp_   = delay_ms;  // 表示開始
    priod_       = priod_ms;  // 表示開始から完了までの期間
  }

  void draw(float x, float y) {
    // 開始指示からの経過時間を取得
    int time = millis() - time_start_;
    
    // 一度もstartが呼ばれてない(time_start_が初期値)なら、何もしない
    if ( time_start_ == -1 ) return;
        
    // 表示開始の時間まで、何もしない
    if ( time < time_disp_ )  return;

    // 表示する文字数を決定
    int len = 0;
    // 表示開始からの経過時間に応じ、表示文字数を増加させる
    if ( time < (time_disp_ + priod_) ) {
      float coef = (float(time) - float(time_disp_)) / float(priod_);
      len = int(float(text_.length()) * coef);
    }
    // 一定時間経過で全文字表示
    else {
      len = text_.length();
    }

    // 指定文字列の一部 ＋ 不足時はランダムな文字１つを表示
    String str = text_.substring(0, len);
    if ( len < text_.length() ) {
      str += str(RANDOM_CHAR.charAt(int(random(0, RANDOM_CHAR.length()))));
    }  
    text(str, x, y);
  }
}
